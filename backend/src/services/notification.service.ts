import { type Prisma } from '@prisma/client';
import prisma from '../config/db.js';
import type { NotificationType } from '@prisma/client';
import { sendPushNotification } from './push.service.js';

async function isProUser(userId: string): Promise<boolean> {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { pro_expires_at: true },
  });
  if (!user || !user.pro_expires_at) return false;
  return user.pro_expires_at > new Date();
}

export async function createNotification(
  userId: string,
  type: NotificationType,
  title: string,
  body: string,
  data?: Record<string, unknown>,
  scheduledAt?: Date,
) {
  const notification = await prisma.notification.create({
    data: {
      user_id: userId,
      type,
      title,
      body,
      data: (data as Prisma.InputJsonValue) ?? undefined,
      scheduled_at: scheduledAt ?? new Date(),
    },
  });

  // Send push notification for pro users (only for immediate notifications)
  const isScheduled = scheduledAt && scheduledAt > new Date();
  if (!isScheduled) {
    try {
      const isPro = await isProUser(userId);
      if (isPro) {
        const pushData: Record<string, string> = { type };
        if (data) {
          for (const [key, value] of Object.entries(data)) {
            pushData[key] = String(value);
          }
        }
        await sendPushNotification(userId, title, body, pushData);
      }
    } catch (error) {
      // Don't fail the notification creation if push fails
      console.error('[Notification] Failed to send push notification:', error);
    }
  }

  return notification;
}

/**
 * Create a notification when a new reservation is created.
 */
export async function notifyReservationCreated(
  userId: string,
  guestName: string,
  checkInDate: string,
  reservationId: string,
) {
  await createNotification(
    userId,
    'reservation_created',
    'New booking confirmed',
    `New booking confirmed: ${guestName} checks in ${checkInDate}`,
    { reservation_id: reservationId },
  );
}

/**
 * Schedule check-in reminder for the day before check-in at 08:00.
 */
export async function scheduleCheckInReminder(
  userId: string,
  guestName: string,
  checkInDate: Date,
  checkInTime: string,
  reservationId: string,
) {
  const reminderDate = new Date(checkInDate);
  reminderDate.setDate(reminderDate.getDate() - 1);
  reminderDate.setHours(8, 0, 0, 0);

  // Only schedule if the reminder is in the future
  if (reminderDate > new Date()) {
    await createNotification(
      userId,
      'check_in_today',
      'Check-in tomorrow',
      `Tomorrow's check-in: ${guestName} at ${checkInTime}`,
      { reservation_id: reservationId },
      reminderDate,
    );
  }
}

/**
 * Schedule check-out reminder for 08:00 on the check-out day.
 */
export async function scheduleCheckOutReminder(
  userId: string,
  guestName: string,
  checkOutDate: Date,
  checkOutTime: string,
  reservationId: string,
) {
  const reminderDate = new Date(checkOutDate);
  reminderDate.setHours(8, 0, 0, 0);

  // Only schedule if the reminder is in the future
  if (reminderDate > new Date()) {
    await createNotification(
      userId,
      'check_out_today',
      'Check-out today',
      `${guestName} checks out today at ${checkOutTime}`,
      { reservation_id: reservationId },
      reminderDate,
    );
  }
}
