import type { Request, Response } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../../utils/asyncHandler.js';
import { ApiError } from '../../utils/ApiError.js';
import prisma from '../../config/db.js';
import { generateTaxReportPdf } from '../../services/pdf-report.service.js';

const taxReportSchema = z.union([
  z.object({
    year: z.number().int().min(2000).max(2100),
    startDate: z.undefined().optional(),
    endDate: z.undefined().optional(),
  }),
  z.object({
    year: z.undefined().optional(),
    startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
    endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  }),
]);

export const generateTaxReport = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;

  // Parse and validate body
  const body = taxReportSchema.parse(req.body);

  // Get user and check PRO subscription
  const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });

  const now = new Date();
  const hasPro =
    user.has_lifetime_tax_report ||
    (user.pro_expires_at !== null && user.pro_expires_at > now);

  if (!hasPro) {
    throw new ApiError(403, 'PRO_REQUIRED');
  }

  // Determine period
  let startDate: Date;
  let endDate: Date;
  let periodLabel: string;

  if (body.year !== undefined && body.year !== null) {
    startDate = new Date(Date.UTC(body.year, 0, 1));
    endDate = new Date(Date.UTC(body.year, 11, 31, 23, 59, 59));
    periodLabel = `Year ${body.year}`;
  } else {
    startDate = new Date(body.startDate + 'T00:00:00.000Z');
    endDate = new Date(body.endDate + 'T23:59:59.999Z');
    periodLabel = `${body.startDate} – ${body.endDate}`;
  }

  // Fetch reservations for the period
  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { gte: startDate },
      check_out: { lte: endDate },
    },
    include: {
      guest: { select: { full_name: true } },
    },
    orderBy: { check_in: 'asc' },
  });

  // Fetch expenses for the period
  const expenses = await prisma.expense.findMany({
    where: {
      user_id: userId,
      date: { gte: startDate, lte: endDate },
    },
    orderBy: { date: 'asc' },
  });

  // Generate PDF
  const pdfDoc = generateTaxReportPdf({
    user: {
      full_name: user.full_name,
      property_name: user.property_name,
      currency: user.currency,
    },
    periodLabel,
    startDate,
    endDate,
    reservations,
    expenses,
  });

  // Stream PDF to response
  const filename = `RentMate_Tax_Report_${periodLabel.replace(/\s+/g, '_')}.pdf`;
  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

  pdfDoc.pipe(res);
});
