import type { Request, Response } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../../utils/asyncHandler.js';
import * as propertiesService from './properties.service.js';

const createPropertySchema = z.object({
  name: z.string().min(1),
  address: z.string().nullable().optional(),
  property_type: z.string().nullable().optional(),
  default_price_per_night: z.number().int().min(0).optional(),
  check_in_time: z.string().optional(),
  check_out_time: z.string().optional(),
  currency: z.string().optional(),
});

const updatePropertySchema = createPropertySchema.partial();

export const list = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await propertiesService.listProperties(userId);
  res.json({ data });
});

export const getById = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await propertiesService.getPropertyById(userId, req.params['id'] as string);
  res.json({ data });
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = createPropertySchema.parse(req.body);
  const data = await propertiesService.createProperty(userId, body);
  res.status(201).json({ data, message: 'Property created' });
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = updatePropertySchema.parse(req.body);
  const data = await propertiesService.updateProperty(
    userId,
    req.params['id'] as string,
    body,
  );
  res.json({ data, message: 'Property updated' });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await propertiesService.deleteProperty(userId, req.params['id'] as string);
  res.json({ data });
});
