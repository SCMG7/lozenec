import type { Request, Response } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../../utils/asyncHandler.js';
import { ApiError } from '../../utils/ApiError.js';
import * as reservationsService from './reservations.service.js';

const createReservationSchema = z.object({
  guest_id: z.string().uuid(),
  check_in: z.string(),
  check_out: z.string(),
  num_guests: z.number().int().min(1).default(1),
  price_per_night: z.number().int().min(0),
  total_price: z.number().int().min(0),
  amount_paid: z.number().int().min(0).optional(),
  payment_status: z.enum(['paid', 'partial', 'unpaid']).optional(),
  payment_method: z.enum(['cash', 'bank_transfer', 'card', 'other']).nullable().optional(),
  status: z.enum(['confirmed', 'pending', 'cancelled']).optional(),
  source: z.string().nullable().optional(),
  notes: z.string().nullable().optional(),
});

const updateReservationSchema = createReservationSchema.partial();

export const getCalendar = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const month = req.query['month'] as string | undefined;
  if (!month || !/^\d{4}-\d{2}$/.test(month)) {
    throw ApiError.badRequest('month query param required in YYYY-MM format');
  }
  const data = await reservationsService.getCalendar(userId, month);
  res.json({ data });
});

export const checkConflict = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const checkIn = req.query['check_in'] as string | undefined;
    const checkOut = req.query['check_out'] as string | undefined;
    const excludeId = req.query['exclude_id'] as string | undefined;
    if (!checkIn || !checkOut) {
      throw ApiError.badRequest('check_in and check_out query params required');
    }
    const data = await reservationsService.checkConflict(
      userId,
      checkIn,
      checkOut,
      excludeId,
    );
    res.json({ data });
  },
);

export const getByDate = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const date = req.query['date'] as string | undefined;
  if (!date) {
    throw ApiError.badRequest('date query param required');
  }
  const data = await reservationsService.getReservationsByDate(userId, date);
  res.json({ data });
});

export const getById = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await reservationsService.getReservationById(
    userId,
    req.params['id'] as string,
  );
  res.json({ data });
});

export const getSummary = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await reservationsService.getReservationSummary(
    userId,
    req.params['id'] as string,
  );
  res.json({ data });
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = createReservationSchema.parse(req.body);
  const data = await reservationsService.createReservation(userId, body);
  res.status(201).json({ data, message: 'Reservation created' });
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = updateReservationSchema.parse(req.body);
  const data = await reservationsService.updateReservation(
    userId,
    req.params['id'] as string,
    body,
  );
  res.json({ data, message: 'Reservation updated' });
});

export const markPaid = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await reservationsService.markAsPaid(
    userId,
    req.params['id'] as string,
  );
  res.json({ data, message: 'Reservation marked as paid' });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await reservationsService.deleteReservation(
    userId,
    req.params['id'] as string,
  );
  res.json({ data });
});
