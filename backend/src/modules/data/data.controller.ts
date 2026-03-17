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
  const exportFormat = (req.query['format'] as string | undefined) ?? 'csv';

  const [user, reservations, guests, expenses] = await Promise.all([
    prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true, email: true, full_name: true, currency: true, language: true,
        default_price_per_night: true, check_in_time: true, check_out_time: true,
        property_name: true, property_address: true, property_type: true,
        created_at: true,
      },
    }),
    prisma.reservation.findMany({
      where: { user_id: userId },
      include: { guest: { select: { full_name: true } } },
      orderBy: { check_in: 'desc' },
    }),
    prisma.guest.findMany({
      where: { user_id: userId },
      orderBy: { full_name: 'asc' },
    }),
    prisma.expense.findMany({
      where: { user_id: userId },
      orderBy: { date: 'desc' },
    }),
  ]);

  if (exportFormat === 'json') {
    res.json({
      data: {
        user: user ? {
          id: user.id, email: user.email, full_name: user.full_name,
          currency: user.currency, language: user.language,
          default_price_per_night: user.default_price_per_night,
          check_in_time: user.check_in_time, check_out_time: user.check_out_time,
          property_name: user.property_name, property_address: user.property_address,
          property_type: user.property_type, created_at: user.created_at.toISOString(),
        } : null,
        reservations: reservations.map((r) => ({
          id: r.id, guest_name: r.guest.full_name, guest_id: r.guest_id,
          check_in: r.check_in.toISOString(), check_out: r.check_out.toISOString(),
          num_guests: r.num_guests, price_per_night: r.price_per_night,
          total_price: r.total_price, amount_paid: r.amount_paid,
          deposit_amount: r.deposit_amount, deposit_received: r.deposit_received,
          payment_status: r.payment_status, payment_method: r.payment_method,
          status: r.status, source: r.source, notes: r.notes,
          created_at: r.created_at.toISOString(),
        })),
        guests: guests.map((g) => ({
          id: g.id, first_name: g.first_name, last_name: g.last_name,
          full_name: g.full_name, email: g.email, phone: g.phone,
          country: g.country, notes: g.notes, created_at: g.created_at.toISOString(),
        })),
        expenses: expenses.map((e) => ({
          id: e.id, category: e.category, amount: e.amount,
          description: e.description, date: e.date.toISOString(),
          is_recurring: e.is_recurring, recurrence_frequency: e.recurrence_frequency,
          created_at: e.created_at.toISOString(),
        })),
      },
      message: 'Data exported successfully',
    });
    return;
  }

  // CSV export (default)
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
  await prisma.deviceToken.deleteMany({ where: { user_id: userId } });
  await prisma.property.deleteMany({ where: { user_id: userId } });

  res.json({ data: null, message: 'All user data has been deleted' });
});
