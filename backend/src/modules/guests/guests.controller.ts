import type { Request, Response } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../../utils/asyncHandler.js';
import * as guestsService from './guests.service.js';

const createGuestSchema = z.object({
  full_name: z.string().min(1),
  email: z.string().email().nullable().optional(),
  phone: z.string().nullable().optional(),
  notes: z.string().nullable().optional(),
  country: z.string().nullable().optional(),
  id_number: z.string().nullable().optional(),
});

const updateGuestSchema = createGuestSchema.partial();

export const list = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const search = req.query['search'] as string | undefined;
  const filter = (req.query['filter'] as string | undefined) ?? 'all';
  const sort = (req.query['sort'] as string | undefined) ?? 'name_asc';
  const page = parseInt((req.query['page'] as string) || '1', 10);
  const limit = parseInt((req.query['limit'] as string) || '20', 10);

  const data = await guestsService.listGuests({
    userId,
    search,
    filter: filter as 'all' | 'upcoming' | 'past' | 'cancelled',
    sort: sort as 'name_asc' | 'name_desc' | 'recent' | 'oldest',
    page,
    limit,
  });
  res.json({ data });
});

export const search = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const q = (req.query['q'] as string) || '';
  const data = await guestsService.searchGuests(userId, q);
  res.json({ data });
});

export const getById = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await guestsService.getGuestById(userId, req.params['id'] as string);
  res.json({ data });
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = createGuestSchema.parse(req.body);
  const data = await guestsService.createGuest(userId, body);
  res.status(201).json({ data, message: 'Guest created' });
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = updateGuestSchema.parse(req.body);
  const data = await guestsService.updateGuest(userId, req.params['id'] as string, body);
  res.json({ data, message: 'Guest updated' });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await guestsService.deleteGuest(userId, req.params['id'] as string);
  res.json({ data });
});
