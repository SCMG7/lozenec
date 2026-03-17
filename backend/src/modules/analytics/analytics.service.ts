import prisma from '../../config/db.js';
import { getMonthRange, countNightsInRange } from '../../utils/dateHelpers.js';
import {
  startOfMonth,
  endOfMonth,
  subMonths,
  subDays,
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
  } else if (period === 'year' || period === 'this_year') {
    rangeStart = new Date(now.getFullYear(), 0, 1);
    rangeEnd = new Date(now.getFullYear(), 11, 31);
  } else if (period === 'quarter') {
    const quarterStart = Math.floor(now.getMonth() / 3) * 3;
    rangeStart = new Date(now.getFullYear(), quarterStart, 1);
    rangeEnd = endOfMonth(new Date(now.getFullYear(), quarterStart + 2, 1));
  } else if (period === 'last_month') {
    const lastMonth = subMonths(now, 1);
    rangeStart = startOfMonth(lastMonth);
    rangeEnd = endOfMonth(lastMonth);
  } else if (period === 'last_3_months') {
    rangeStart = startOfMonth(subMonths(now, 2));
    rangeEnd = endOfMonth(now);
  } else if (period === 'last_6_months') {
    rangeStart = startOfMonth(subMonths(now, 5));
    rangeEnd = endOfMonth(now);
  } else {
    // Default: current month (handles 'month' and 'this_month')
    rangeStart = startOfMonth(now);
    rangeEnd = endOfMonth(now);
  }

  // Enforce free-tier 90-day clamp
  const isPro = await isUserPro(userId);
  rangeStart = clampDateForFreeUser(isPro, rangeStart);

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

  // ----- Reservation stats (Flutter: ReservationStats) -----
  let longestStay = 0;
  let longestStayGuest: string | null = null;

  const guestStayCounts: Record<string, { name: string; count: number }> = {};

  for (const r of reservations) {
    const nights = differenceInCalendarDays(r.check_out, r.check_in);
    if (nights > longestStay) {
      longestStay = nights;
      longestStayGuest = r.guest.full_name;
    }
    const existing = guestStayCounts[r.guest_id];
    if (existing) {
      existing.count += 1;
    } else {
      guestStayCounts[r.guest_id] = { name: r.guest.full_name, count: 1 };
    }
  }

  let mostFrequentGuest: string | null = null;
  let mostFrequentGuestStays = 0;
  for (const data of Object.values(guestStayCounts)) {
    if (data.count > mostFrequentGuestStays) {
      mostFrequentGuestStays = data.count;
      mostFrequentGuest = data.name;
    }
  }

  const avgRevenuePerReservation =
    reservations.length > 0
      ? Math.round(totalRevenue / reservations.length)
      : 0;

  // ----- Revenue chart (Flutter: List<RevenueChartPoint>) -----
  // Each point has { month, confirmedRevenue, pendingRevenue }
  const revenueChart = monthlyData.map((m) => {
    const monthReservations = reservations.filter(
      (r) => {
        const mStart = startOfMonth(new Date(m.month + '-01'));
        const mEnd = endOfMonth(mStart);
        return r.check_in <= mEnd && r.check_out >= mStart;
      },
    );
    const confirmed = monthReservations
      .filter((r) => r.payment_status === 'paid')
      .reduce((sum, r) => sum + r.total_price, 0);
    const pending = monthReservations
      .filter((r) => r.payment_status !== 'paid')
      .reduce((sum, r) => sum + r.total_price, 0);

    return {
      month: m.month,
      confirmedRevenue: confirmed,
      pendingRevenue: pending,
    };
  });

  // ----- Expenses breakdown (Flutter: List<ExpenseCategoryBreakdown>) -----
  const expensesBreakdown = Object.entries(expensesByCategory).map(
    ([category, total]) => ({
      category,
      total,
      percentage:
        totalExpenses > 0
          ? Math.round((total / totalExpenses) * 1000) / 10
          : 0,
    }),
  );

  // ----- Monthly comparison rows (Flutter: List<MonthlyComparisonRow>) -----
  const monthlyComparison = monthlyData.map((m) => ({
    month: m.month,
    nightsBooked: m.nights,
    revenue: m.revenue,
    expenses: m.expenses,
    netProfit: m.revenue - m.expenses,
  }));

  // ----- Occupancy (Flutter: OccupancyData) -----
  // rate is a 0..1 double in Flutter (used as CircularProgressIndicator value)
  const occupancyRateDecimal =
    totalDaysInRange > 0 ? occupiedNights / totalDaysInRange : 0;

  return {
    totalRevenue,
    totalExpenses,
    netProfit,
    occupancy: {
      rate: occupancyRateDecimal,
      bookedNights: occupiedNights,
      totalNights: totalDaysInRange,
    },
    revenueChart,
    expensesBreakdown,
    reservationStats: {
      avgLengthOfStay: avgStayLength,
      avgRevenuePerReservation,
      longestStay,
      longestStayGuest,
      mostFrequentGuest,
      mostFrequentGuestStays,
    },
    monthlyComparison,
  };
}

// ---------------------------------------------------------------------------
// Subscription helper: checks if user is PRO
// ---------------------------------------------------------------------------
export async function isUserPro(userId: string): Promise<boolean> {
  const user = await prisma.user.findUniqueOrThrow({ where: { id: userId } });
  const now = new Date();
  return (
    user.has_lifetime_tax_report ||
    (user.pro_expires_at !== null && user.pro_expires_at > now)
  );
}

/**
 * For free users, clamp startDate to max 90 days ago.
 */
export function clampDateForFreeUser(
  isPro: boolean,
  startDate: Date,
): Date {
  if (isPro) return startDate;
  const minDate = subDays(new Date(), 90);
  return startDate < minDate ? minDate : startDate;
}

// ---------------------------------------------------------------------------
// GET /api/v1/analytics/summary?startDate=&endDate=
// ---------------------------------------------------------------------------
interface SummaryParams {
  userId: string;
  startDate: string;
  endDate: string;
}

export async function getSummary(params: SummaryParams) {
  const { userId } = params;
  const isPro = await isUserPro(userId);

  let rangeStart = new Date(params.startDate);
  const rangeEnd = new Date(params.endDate);

  rangeStart = clampDateForFreeUser(isPro, rangeStart);

  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: rangeEnd },
      check_out: { gte: rangeStart },
      status: { not: 'cancelled' },
    },
    include: { guest: { select: { id: true } } },
  });

  const expenses = await prisma.expense.findMany({
    where: {
      user_id: userId,
      date: { gte: rangeStart, lte: rangeEnd },
    },
  });

  const totalRevenue = reservations.reduce((s, r) => s + r.total_price, 0);
  const totalExpenses = expenses.reduce((s, e) => s + e.amount, 0);
  const netProfit = totalRevenue - totalExpenses;

  let totalNights = 0;
  for (const r of reservations) {
    totalNights += countNightsInRange(r.check_in, r.check_out, rangeStart, rangeEnd);
  }

  const totalDaysInPeriod = differenceInCalendarDays(rangeEnd, rangeStart) + 1;
  const occupancyRate =
    totalDaysInPeriod > 0
      ? parseFloat(((totalNights / totalDaysInPeriod) * 100).toFixed(2))
      : 0;
  const avgNightlyRate =
    totalNights > 0 ? Math.round(totalRevenue / totalNights) : 0;

  const uniqueGuestIds = new Set(reservations.map((r) => r.guest_id));

  return {
    total_revenue: totalRevenue,
    total_expenses: totalExpenses,
    net_profit: netProfit,
    total_nights: totalNights,
    total_days_in_period: totalDaysInPeriod,
    occupancy_rate: occupancyRate,
    avg_nightly_rate: avgNightlyRate,
    total_reservations: reservations.length,
    unique_guests: uniqueGuestIds.size,
  };
}

// ---------------------------------------------------------------------------
// GET /api/v1/analytics/monthly?year=
// ---------------------------------------------------------------------------
interface MonthlyParams {
  userId: string;
  year: number;
}

export async function getMonthly(params: MonthlyParams) {
  const { userId, year } = params;
  const isPro = await isUserPro(userId);

  let rangeStart = new Date(Date.UTC(year, 0, 1));
  const rangeEnd = new Date(Date.UTC(year, 11, 31, 23, 59, 59));

  rangeStart = clampDateForFreeUser(isPro, rangeStart);

  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: rangeEnd },
      check_out: { gte: rangeStart },
      status: { not: 'cancelled' },
    },
  });

  const expenses = await prisma.expense.findMany({
    where: {
      user_id: userId,
      date: { gte: rangeStart, lte: rangeEnd },
    },
  });

  const months = eachMonthOfInterval({ start: rangeStart, end: rangeEnd });

  const monthlyRows = months.map((monthDate) => {
    const mStart = startOfMonth(monthDate);
    const mEnd = endOfMonth(monthDate);
    const monthLabel = format(monthDate, 'yyyy-MM');

    const monthReservations = reservations.filter(
      (r) => r.check_in <= mEnd && r.check_out >= mStart,
    );

    const revenue = monthReservations.reduce((s, r) => s + r.total_price, 0);

    const monthExpenses = expenses
      .filter((e) => e.date >= mStart && e.date <= mEnd)
      .reduce((s, e) => s + e.amount, 0);

    let nights = 0;
    for (const r of monthReservations) {
      nights += countNightsInRange(r.check_in, r.check_out, mStart, mEnd);
    }

    return {
      month: monthLabel,
      reservations: monthReservations.length,
      nights,
      revenue,
      expenses: monthExpenses,
      net: revenue - monthExpenses,
    };
  });

  return { months: monthlyRows };
}

// ---------------------------------------------------------------------------
// GET /api/v1/analytics/top-guests?limit=5&startDate=&endDate=
// ---------------------------------------------------------------------------
interface TopGuestsParams {
  userId: string;
  limit: number;
  startDate: string;
  endDate: string;
}

export async function getTopGuests(params: TopGuestsParams) {
  const { userId, limit } = params;
  const isPro = await isUserPro(userId);

  let rangeStart = new Date(params.startDate);
  const rangeEnd = new Date(params.endDate);

  rangeStart = clampDateForFreeUser(isPro, rangeStart);

  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: rangeEnd },
      check_out: { gte: rangeStart },
      status: { not: 'cancelled' },
    },
    include: { guest: { select: { id: true, full_name: true } } },
  });

  const guestMap: Record<
    string,
    { name: string; total_paid: number; total_nights: number; reservation_count: number }
  > = {};

  for (const r of reservations) {
    const nights = countNightsInRange(r.check_in, r.check_out, rangeStart, rangeEnd);
    const existing = guestMap[r.guest_id];
    if (existing) {
      existing.total_paid += r.total_price;
      existing.total_nights += nights;
      existing.reservation_count += 1;
    } else {
      guestMap[r.guest_id] = {
        name: r.guest.full_name,
        total_paid: r.total_price,
        total_nights: nights,
        reservation_count: 1,
      };
    }
  }

  const guests = Object.entries(guestMap)
    .map(([id, data]) => ({ id, ...data }))
    .sort((a, b) => b.total_paid - a.total_paid)
    .slice(0, limit);

  return { guests };
}
