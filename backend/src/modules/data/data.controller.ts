import type { Request, Response } from 'express';
import { z } from 'zod';
import { format } from 'date-fns';
import prisma from '../../config/db.js';
import { asyncHandler } from '../../utils/asyncHandler.js';
import { ApiError } from '../../utils/ApiError.js';

const clearDataSchema = z.object({
  confirmation: z.literal('DELETE'),
});

export const exportData = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;

  const [reservations, expenses] = await Promise.all([
    prisma.reservation.findMany({
      where: { user_id: userId },
      include: { guest: { select: { full_name: true } } },
      orderBy: { check_in: 'desc' },
    }),
    prisma.expense.findMany({
      where: { user_id: userId },
      orderBy: { date: 'desc' },
    }),
  ]);

  // Build CSV for reservations
  const resCsvHeader =
    'Type,Guest Name,Check In,Check Out,Nights,Price/Night,Total Price,Amount Paid,Payment Status,Status,Source,Notes';
  const resCsvRows = reservations.map((r) => {
    const nights = Math.ceil(
      (r.check_out.getTime() - r.check_in.getTime()) / 86400000,
    );
    return [
      'Reservation',
      `"${r.guest.full_name}"`,
      format(r.check_in, 'yyyy-MM-dd'),
      format(r.check_out, 'yyyy-MM-dd'),
      nights,
      (r.price_per_night / 100).toFixed(2),
      (r.total_price / 100).toFixed(2),
      (r.amount_paid / 100).toFixed(2),
      r.payment_status,
      r.status,
      r.source ?? '',
      `"${(r.notes ?? '').replace(/"/g, '""')}"`,
    ].join(',');
  });

  // Build CSV for expenses
  const expCsvHeader = 'Type,Category,Amount,Description,Date';
  const expCsvRows = expenses.map((e) => {
    return [
      'Expense',
      e.category,
      (e.amount / 100).toFixed(2),
      `"${(e.description ?? '').replace(/"/g, '""')}"`,
      format(e.date, 'yyyy-MM-dd'),
    ].join(',');
  });

  const csv = [
    '--- RESERVATIONS ---',
    resCsvHeader,
    ...resCsvRows,
    '',
    '--- EXPENSES ---',
    expCsvHeader,
    ...expCsvRows,
  ].join('\n');

  res.json({
    data: {
      csv,
      reservations_count: reservations.length,
      expenses_count: expenses.length,
    },
    message: 'Data exported successfully',
  });
});

export const clearData = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = clearDataSchema.parse(req.body);

  if (body.confirmation !== 'DELETE') {
    throw ApiError.badRequest(
      'Must send { confirmation: "DELETE" } to confirm',
    );
  }

  // Delete in order to respect foreign keys
  await prisma.reservationActivityLog.deleteMany({
    where: { user_id: userId },
  });
  await prisma.notification.deleteMany({ where: { user_id: userId } });
  await prisma.expense.deleteMany({ where: { user_id: userId } });
  await prisma.reservation.deleteMany({ where: { user_id: userId } });
  await prisma.guest.deleteMany({ where: { user_id: userId } });
  await prisma.passwordResetToken.deleteMany({ where: { user_id: userId } });

  res.json({ data: null, message: 'All user data has been deleted' });
});
