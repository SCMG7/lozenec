import prisma from '../../config/db.js';
import { getMonthRange, countNightsInRange } from '../../utils/dateHelpers.js';
import {
  startOfMonth,
  endOfMonth,
  subMonths,
  format,
  differenceInCalendarDays,
  eachMonthOfInterval,
} from 'date-fns';

interface AnalyticsParams {
  userId: string;
  period?: string; // 'month' | 'quarter' | 'year' | 'custom'
  startDate?: string;
  endDate?: string;
}

export async function getAnalytics(params: AnalyticsParams) {
  const { userId, period = 'month', startDate, endDate } = params;

  let rangeStart: Date;
  let rangeEnd: Date;

  const now = new Date();

  if (period === 'custom' && startDate && endDate) {
    rangeStart = new Date(startDate);
    rangeEnd = new Date(endDate);
  } else if (period === 'year') {
    rangeStart = new Date(now.getFullYear(), 0, 1);
    rangeEnd = new Date(now.getFullYear(), 11, 31);
  } else if (period === 'quarter') {
    const quarterStart = Math.floor(now.getMonth() / 3) * 3;
    rangeStart = new Date(now.getFullYear(), quarterStart, 1);
    rangeEnd = endOfMonth(new Date(now.getFullYear(), quarterStart + 2, 1));
  } else {
    // Default: current month
    rangeStart = startOfMonth(now);
    rangeEnd = endOfMonth(now);
  }

  // Get reservations in range
  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: rangeEnd },
      check_out: { gte: rangeStart },
      status: { not: 'cancelled' },
    },
    include: {
      guest: { select: { full_name: true } },
    },
    orderBy: { check_in: 'asc' },
  });

  // Get expenses in range
  const expenses = await prisma.expense.findMany({
    where: {
      user_id: userId,
      date: { gte: rangeStart, lte: rangeEnd },
    },
  });

  // Revenue calculations
  const totalRevenue = reservations.reduce((sum, r) => sum + r.total_price, 0);
  const totalCollected = reservations.reduce(
    (sum, r) => sum + r.amount_paid,
    0,
  );
  const totalOutstanding = totalRevenue - totalCollected;

  // Expense calculations
  const totalExpenses = expenses.reduce((sum, e) => sum + e.amount, 0);
  const expensesByCategory: Record<string, number> = {};
  for (const e of expenses) {
    expensesByCategory[e.category] =
      (expensesByCategory[e.category] ?? 0) + e.amount;
  }

  // Net profit
  const netProfit = totalCollected - totalExpenses;

  // Occupancy calculation
  const totalDaysInRange = differenceInCalendarDays(rangeEnd, rangeStart) + 1;
  let occupiedNights = 0;
  for (const r of reservations) {
    occupiedNights += countNightsInRange(
      r.check_in,
      r.check_out,
      rangeStart,
      rangeEnd,
    );
  }
  const occupancyRate =
    totalDaysInRange > 0
      ? Math.round((occupiedNights / totalDaysInRange) * 100)
      : 0;

  // Average nightly rate
  const avgNightlyRate =
    occupiedNights > 0 ? Math.round(totalRevenue / occupiedNights) : 0;

  // Average stay length
  const avgStayLength =
    reservations.length > 0
      ? Math.round(
          reservations.reduce(
            (sum, r) =>
              sum + differenceInCalendarDays(r.check_out, r.check_in),
            0,
          ) / reservations.length,
        )
      : 0;

  // Payment status breakdown
  const paymentBreakdown = {
    paid: reservations.filter((r) => r.payment_status === 'paid').length,
    partial: reservations.filter((r) => r.payment_status === 'partial').length,
    unpaid: reservations.filter((r) => r.payment_status === 'unpaid').length,
  };

  // Monthly chart data
  const months = eachMonthOfInterval({ start: rangeStart, end: rangeEnd });
  const monthlyData = months.map((monthDate) => {
    const mStart = startOfMonth(monthDate);
    const mEnd = endOfMonth(monthDate);
    const monthLabel = format(monthDate, 'yyyy-MM');

    const monthRevenue = reservations
      .filter((r) => r.check_in <= mEnd && r.check_out >= mStart)
      .reduce((sum, r) => sum + r.total_price, 0);

    const monthExpenses = expenses
      .filter((e) => e.date >= mStart && e.date <= mEnd)
      .reduce((sum, e) => sum + e.amount, 0);

    let monthNights = 0;
    for (const r of reservations) {
      monthNights += countNightsInRange(r.check_in, r.check_out, mStart, mEnd);
    }

    const daysInMonth = differenceInCalendarDays(mEnd, mStart) + 1;
    const monthOccupancy =
      daysInMonth > 0 ? Math.round((monthNights / daysInMonth) * 100) : 0;

    return {
      month: monthLabel,
      revenue: monthRevenue,
      expenses: monthExpenses,
      net_profit: monthRevenue - monthExpenses,
      occupancy: monthOccupancy,
      nights: monthNights,
      reservations: reservations.filter(
        (r) => r.check_in <= mEnd && r.check_out >= mStart,
      ).length,
    };
  });

  // Previous period comparison
  const periodDays = differenceInCalendarDays(rangeEnd, rangeStart) + 1;
  const prevStart = subMonths(rangeStart, Math.ceil(periodDays / 30));
  const prevEnd = subMonths(rangeEnd, Math.ceil(periodDays / 30));

  const prevReservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: prevEnd },
      check_out: { gte: prevStart },
      status: { not: 'cancelled' },
    },
  });
  const prevExpenses = await prisma.expense.findMany({
    where: {
      user_id: userId,
      date: { gte: prevStart, lte: prevEnd },
    },
  });

  const prevRevenue = prevReservations.reduce(
    (sum, r) => sum + r.total_price,
    0,
  );
  const prevExpenseTotal = prevExpenses.reduce(
    (sum, e) => sum + e.amount,
    0,
  );

  const revenueChange =
    prevRevenue > 0
      ? Math.round(((totalRevenue - prevRevenue) / prevRevenue) * 100)
      : totalRevenue > 0
        ? 100
        : 0;

  const expenseChange =
    prevExpenseTotal > 0
      ? Math.round(
          ((totalExpenses - prevExpenseTotal) / prevExpenseTotal) * 100,
        )
      : totalExpenses > 0
        ? 100
        : 0;

  // Top guests by spend
  const guestSpend: Record<string, { name: string; total: number; visits: number }> =
    {};
  for (const r of reservations) {
    const existing = guestSpend[r.guest_id];
    if (existing) {
      existing.total += r.total_price;
      existing.visits += 1;
    } else {
      guestSpend[r.guest_id] = {
        name: r.guest.full_name,
        total: r.total_price,
        visits: 1,
      };
    }
  }
  const topGuests = Object.entries(guestSpend)
    .map(([id, data]) => ({ guest_id: id, ...data }))
    .sort((a, b) => b.total - a.total)
    .slice(0, 5);

  return {
    period: {
      start: rangeStart.toISOString(),
      end: rangeEnd.toISOString(),
      type: period,
    },
    revenue: {
      total: totalRevenue,
      collected: totalCollected,
      outstanding: totalOutstanding,
      change_percent: revenueChange,
    },
    expenses: {
      total: totalExpenses,
      by_category: expensesByCategory,
      change_percent: expenseChange,
    },
    profit: {
      net: netProfit,
    },
    occupancy: {
      rate: occupancyRate,
      occupied_nights: occupiedNights,
      total_days: totalDaysInRange,
    },
    averages: {
      nightly_rate: avgNightlyRate,
      stay_length: avgStayLength,
    },
    reservations_count: reservations.length,
    payment_breakdown: paymentBreakdown,
    monthly_chart: monthlyData,
    top_guests: topGuests,
    comparison: {
      prev_revenue: prevRevenue,
      prev_expenses: prevExpenseTotal,
      revenue_change_percent: revenueChange,
      expense_change_percent: expenseChange,
    },
  };
}
