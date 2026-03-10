import type { Request, Response } from 'express';
import { asyncHandler } from '../../utils/asyncHandler.js';
import * as notificationsService from './notifications.service.js';

export const list = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const page = parseInt((req.query['page'] as string) || '1', 10);
  const limit = parseInt((req.query['limit'] as string) || '20', 10);
  const data = await notificationsService.listNotifications(
    userId,
    page,
    limit,
  );
  res.json({ data });
});

export const getUnreadCount = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const data = await notificationsService.getUnreadCount(userId);
    res.json({ data });
  },
);

export const markRead = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await notificationsService.markAsRead(
    userId,
    req.params['id'] as string,
  );
  res.json({ data, message: 'Notification marked as read' });
});

export const markAllRead = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const data = await notificationsService.markAllAsRead(userId);
    res.json({ data, message: 'All notifications marked as read' });
  },
);
