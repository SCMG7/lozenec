import prisma from '../../config/db.js';
import { startOfMonth, endOfMonth, getDaysInMonth } from 'date-fns';

export async function getDashboardData(userId: string) {
  const now = new Date();
  const monthStart = startOfMonth(now);
  const monthEnd = endOfMonth(now);
  const today = now.toISOString().split('T')[0];
  const totalDays = getDaysInMonth(now);

  // User name for avatar
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { full_name: true },
  });

  // Tonight's guest
  const tonightReservation = await prisma.reservation.findFirst({
    where: {
      user_id: userId,
      check_in: { lte: new Date(today) },
      check_out: { gt: new Date(today) },
      status: 'confirmed',
    },
    include: { guest: true },
  });

  // Month reservations
  const monthReservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      status: 'confirmed',
      check_in: { lte: monthEnd },
      check_out: { gte: monthStart },
    },
    include: { guest: true },
    orderBy: { check_in: 'asc' },
  });

  // Calculate occupied nights this month
  let monthNightsBooked = 0;
  for (const r of monthReservations) {
    const start = r.check_in > monthStart ? r.check_in : monthStart;
    const end = r.check_out < monthEnd ? r.check_out : monthEnd;
    const diff = Math.ceil((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24));
    monthNightsBooked += Math.max(0, diff);
  }

  const monthRevenue = monthReservations.reduce((sum, r) => sum + r.total_price, 0);

  // Month expenses
  const monthExpensesResult = await prisma.expense.aggregate({
    where: {
      user_id: userId,
      date: { gte: monthStart, lte: monthEnd },
    },
    _sum: { amount: true },
  });
  const monthExpenses = monthExpensesResult._sum.amount ?? 0;

  // Upcoming reservations (next 5)
  const upcoming = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { gte: new Date(today) },
      status: { not: 'cancelled' },
    },
    include: { guest: true },
    orderBy: { check_in: 'asc' },
    take: 5,
  });

  // Unread notifications
  const unreadCount = await prisma.notification.count({
    where: { user_id: userId, is_read: false },
  });

  const occupancyRate = totalDays > 0 ? (monthNightsBooked / totalDays) * 100 : 0;

  return {
    user_name: user?.full_name ?? '',
    tonight_guest: tonightReservation?.guest.full_name ?? null,
    month_nights_booked: monthNightsBooked,
    month_total_nights: totalDays,
    month_revenue: monthRevenue,
    occupancy_rate: Math.round(occupancyRate * 10) / 10,
    month_expenses: monthExpenses,
    month_net_profit: monthRevenue - monthExpenses,
    upcoming_reservations: upcoming.map((r) => ({
      id: r.id,
      guest_name: r.guest.full_name,
      check_in: r.check_in.toISOString().split('T')[0],
      check_out: r.check_out.toISOString().split('T')[0],
      status: r.status,
      total_price: r.total_price,
      payment_status: r.payment_status,
    })),
    unread_notification_count: unreadCount,
  };
}
