import type { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler.js';
import * as dashboardService from './dashboard.service.js';

export const getDashboard = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const propertyId = req.query['property_id'] as string | undefined;
  const data = await dashboardService.getDashboardData(userId, propertyId);
  res.json({ data });
});
