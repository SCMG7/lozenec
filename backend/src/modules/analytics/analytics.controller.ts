import type { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler.js';
import * as analyticsService from './analytics.service.js';

export const getAnalytics = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const period = (req.query['period'] as string) || 'month';
    const startDate = req.query['start_date'] as string | undefined;
    const endDate = req.query['end_date'] as string | undefined;

    const data = await analyticsService.getAnalytics({
      userId,
      period,
      startDate,
      endDate,
    });
    res.json({ data });
  },
);
