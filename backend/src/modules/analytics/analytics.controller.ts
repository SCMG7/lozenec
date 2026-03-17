import type { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler.js';
import * as analyticsService from './analytics.service.js';

export const getAnalytics = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const period = (req.query['period'] as string) || 'month';
    const startDate =
      (req.query['startDate'] as string | undefined) ??
      (req.query['start_date'] as string | undefined);
    const endDate =
      (req.query['endDate'] as string | undefined) ??
      (req.query['end_date'] as string | undefined);

    const data = await analyticsService.getAnalytics({
      userId,
      period,
      startDate,
      endDate,
    });
    res.json({ data });
  },
);

export const getSummary = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const startDate = req.query['startDate'] as string;
    const endDate = req.query['endDate'] as string;

    if (!startDate || !endDate) {
      res.status(400).json({ error: 'startDate and endDate are required' });
      return;
    }

    const data = await analyticsService.getSummary({
      userId,
      startDate,
      endDate,
    });
    res.json({ data });
  },
);

export const getMonthly = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const yearStr = req.query['year'] as string;

    if (!yearStr) {
      res.status(400).json({ error: 'year is required' });
      return;
    }

    const year = parseInt(yearStr, 10);
    if (isNaN(year) || year < 2000 || year > 2100) {
      res.status(400).json({ error: 'year must be between 2000 and 2100' });
      return;
    }

    const data = await analyticsService.getMonthly({ userId, year });
    res.json({ data });
  },
);

export const getTopGuests = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const startDate = req.query['startDate'] as string;
    const endDate = req.query['endDate'] as string;
    const limitStr = (req.query['limit'] as string) || '5';
    const limit = Math.min(Math.max(parseInt(limitStr, 10) || 5, 1), 50);

    if (!startDate || !endDate) {
      res.status(400).json({ error: 'startDate and endDate are required' });
      return;
    }

    const data = await analyticsService.getTopGuests({
      userId,
      limit,
      startDate,
      endDate,
    });
    res.json({ data });
  },
);
