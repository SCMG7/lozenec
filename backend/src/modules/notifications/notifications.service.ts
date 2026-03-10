import prisma from '../../config/db.js';
import { ApiError } from '../../utils/ApiError.js';

export async function listNotifications(
  userId: string,
  page: number = 1,
  limit: number = 20,
) {
  const skip = (page - 1) * limit;
  const now = new Date();

  const where = {
    user_id: userId,
    scheduled_at: { lte: now },
  };

  const [notifications, total] = await Promise.all([
    prisma.notification.findMany({
      where,
      orderBy: { created_at: 'desc' },
      skip,
      take: limit,
    }),
    prisma.notification.count({ where }),
  ]);

  return {
    notifications: notifications.map((n) => ({
      id: n.id,
      type: n.type,
      title: n.title,
      body: n.body,
      data: n.data,
      is_read: n.is_read,
      scheduled_at: n.scheduled_at.toISOString(),
      created_at: n.created_at.toISOString(),
    })),
    pagination: {
      page,
      limit,
      total,
      total_pages: Math.ceil(total / limit),
    },
  };
}

export async function getUnreadCount(userId: string) {
  const count = await prisma.notification.count({
    where: {
      user_id: userId,
      is_read: false,
      scheduled_at: { lte: new Date() },
    },
  });
  return { count };
}

export async function markAsRead(userId: string, id: string) {
  const notification = await prisma.notification.findFirst({
    where: { id, user_id: userId },
  });
  if (!notification) {
    throw ApiError.notFound('Notification not found');
  }

  const updated = await prisma.notification.update({
    where: { id },
    data: { is_read: true },
  });

  return {
    id: updated.id,
    is_read: updated.is_read,
  };
}

export async function markAllAsRead(userId: string) {
  const result = await prisma.notification.updateMany({
    where: { user_id: userId, is_read: false },
    data: { is_read: true },
  });

  return { marked_count: result.count };
}
