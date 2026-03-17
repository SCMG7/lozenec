import cron from 'node-cron';
import prisma from '../config/db.js';
import { createNotification } from '../services/notification.service.js';

/**
 * Runs daily at 07:00 to check for unpaid reservations and create reminder notifications.
 */
export function startNotificationSchedulerJob() {
  cron.schedule('0 7 * * *', async () => {
    console.log('[NotificationScheduler] Running notification check...');
    try {
      await processUnpaidReminders();
    } catch (error) {
      console.error('[NotificationScheduler] Error:', error);
    }
  });
  console.log('[NotificationScheduler] Cron job scheduled (daily at 07:00)');
}

async function processUnpaidReminders() {
  const now = new Date();
  const twoDaysAgo = new Date(now);
  twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

  // Find reservations where check-in was 2+ days ago and payment is unpaid
  const unpaidReservations = await prisma.reservation.findMany({
    where: {
      check_in: { lte: twoDaysAgo },
      payment_status: 'unpaid',
      status: { not: 'cancelled' },
    },
    include: {
      guest: { select: { full_name: true } },
      user: { select: { id: true, notify_payment_due: true } },
    },
  });

  let created = 0;
  for (const reservation of unpaidReservations) {
    if (!reservation.user.notify_payment_due) continue;

    // Check if we already sent a payment reminder for this reservation today
    const existingReminder = await prisma.notification.findFirst({
      where: {
        user_id: reservation.user_id,
        type: 'payment_due',
        data: { path: ['reservation_id'], equals: reservation.id },
        created_at: { gte: new Date(now.getFullYear(), now.getMonth(), now.getDate()) },
      },
    });

    if (!existingReminder) {
      await createNotification(
        reservation.user_id,
        'payment_due',
        'Unpaid reservation',
        `Reservation with ${reservation.guest.full_name} is still unpaid`,
        { reservation_id: reservation.id },
      );
      created++;
    }
  }

  if (created > 0) {
    console.log(`[NotificationScheduler] Created ${created} payment reminders`);
  }
}
