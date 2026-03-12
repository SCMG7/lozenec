import prisma from '../../config/db.js';
import { ApiError } from '../../utils/ApiError.js';
import { getMonthRange } from '../../utils/dateHelpers.js';
import {
  startOfMonth,
  endOfMonth,
  subMonths,
  eachMonthOfInterval,
  format,
} from 'date-fns';
import type { ExpenseCategory } from '@prisma/client';

export async function listExpenses(
  userId: string,
  month?: string,
  category?: string,
) {
  const where: Record<string, unknown> = { user_id: userId };

  if (month) {
    const { start, end } = getMonthRange(month);
    where['date'] = { gte: start, lte: end };
  }

  if (category) {
    where['category'] = category;
  }

  const expenses = await prisma.expense.findMany({
    where,
    orderBy: { date: 'desc' },
  });

  // Compute summary by category
  const byCategory: Record<string, number> = {};
  let total = 0;
  for (const e of expenses) {
    total += e.amount;
    byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
  }

  return {
    expenses: expenses.map((e) => ({
      id: e.id,
      category: e.category,
      amount: e.amount,
      description: e.description,
      date: e.date.toISOString(),
      created_at: e.created_at.toISOString(),
    })),
    summary: {
      total,
      by_category: byCategory,
      count: expenses.length,
    },
  };
}

export async function getExpenseById(userId: string, id: string) {
  const expense = await prisma.expense.findFirst({
    where: { id, user_id: userId },
  });
  if (!expense) {
    throw ApiError.notFound('Expense not found');
  }
  return {
    ...expense,
    date: expense.date.toISOString(),
    created_at: expense.created_at.toISOString(),
    updated_at: expense.updated_at.toISOString(),
  };
}

export async function createExpense(
  userId: string,
  data: {
    category: ExpenseCategory;
    amount: number;
    description?: string | null;
    date: string;
  },
) {
  const expense = await prisma.expense.create({
    data: {
      user_id: userId,
      category: data.category,
      amount: data.amount,
      description: data.description ?? null,
      date: new Date(data.date),
    },
  });

  return {
    ...expense,
    date: expense.date.toISOString(),
    created_at: expense.created_at.toISOString(),
    updated_at: expense.updated_at.toISOString(),
  };
}

export async function updateExpense(
  userId: string,
  id: string,
  data: {
    category?: ExpenseCategory;
    amount?: number;
    description?: string | null;
    date?: string;
  },
) {
  const existing = await prisma.expense.findFirst({
    where: { id, user_id: userId },
  });
  if (!existing) {
    throw ApiError.notFound('Expense not found');
  }

  const updateData: Record<string, unknown> = {};
  if (data.category !== undefined) updateData['category'] = data.category;
  if (data.amount !== undefined) updateData['amount'] = data.amount;
  if (data.description !== undefined) updateData['description'] = data.description;
  if (data.date !== undefined) updateData['date'] = new Date(data.date);

  const expense = await prisma.expense.update({
    where: { id },
    data: updateData,
  });

  return {
    ...expense,
    date: expense.date.toISOString(),
    created_at: expense.created_at.toISOString(),
    updated_at: expense.updated_at.toISOString(),
  };
}

export async function deleteExpense(userId: string, id: string) {
  const existing = await prisma.expense.findFirst({
    where: { id, user_id: userId },
  });
  if (!existing) {
    throw ApiError.notFound('Expense not found');
  }

  await prisma.expense.delete({ where: { id } });
  return { message: 'Expense deleted' };
}

function percentChange(current: number, previous: number): number | null {
  if (previous === 0) return current > 0 ? 100 : null;
  return Math.round(((current - previous) / previous) * 1000) / 10;
}

export async function getFinancialSummary(userId: string, month: string) {
  const { start, end } = getMonthRange(month);

  // Revenue: sum amount_paid from non-cancelled reservations overlapping this month
  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: end },
      check_out: { gte: start },
      status: { not: 'cancelled' },
    },
  });
  const revenue = reservations.reduce((sum, r) => sum + r.amount_paid, 0);

  // Expenses for the month
  const expenseResult = await prisma.expense.aggregate({
    where: {
      user_id: userId,
      date: { gte: start, lte: end },
    },
    _sum: { amount: true },
  });
  const expenses = expenseResult._sum.amount ?? 0;

  const netProfit = revenue - expenses;

  // Previous month for comparison
  const prevStart = startOfMonth(subMonths(start, 1));
  const prevEnd = endOfMonth(subMonths(start, 1));

  const prevReservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: prevEnd },
      check_out: { gte: prevStart },
      status: { not: 'cancelled' },
    },
  });
  const prevRevenue = prevReservations.reduce((sum, r) => sum + r.amount_paid, 0);

  const prevExpenseResult = await prisma.expense.aggregate({
    where: {
      user_id: userId,
      date: { gte: prevStart, lte: prevEnd },
    },
    _sum: { amount: true },
  });
  const prevExpenses = prevExpenseResult._sum.amount ?? 0;
  const prevProfit = prevRevenue - prevExpenses;

  return {
    revenue,
    expenses,
    net_profit: netProfit,
    revenue_change: percentChange(revenue, prevRevenue),
    expense_change: percentChange(expenses, prevExpenses),
    profit_change: percentChange(netProfit, prevProfit),
  };
}

export async function getAnnualSummary(userId: string, year: number) {
  const yearStart = new Date(year, 0, 1);
  const yearEnd = new Date(year, 11, 31);

  // All reservations for the year
  const reservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: yearEnd },
      check_out: { gte: yearStart },
      status: { not: 'cancelled' },
    },
  });

  // All expenses for the year
  const expenses = await prisma.expense.findMany({
    where: {
      user_id: userId,
      date: { gte: yearStart, lte: yearEnd },
    },
  });

  const totalRevenue = reservations.reduce((sum, r) => sum + r.amount_paid, 0);
  const totalExpenses = expenses.reduce((sum, e) => sum + e.amount, 0);
  const totalProfit = totalRevenue - totalExpenses;

  // Monthly breakdown
  const months = eachMonthOfInterval({ start: yearStart, end: yearEnd });
  const monthlyBreakdown = months.map((monthDate) => {
    const mStart = startOfMonth(monthDate);
    const mEnd = endOfMonth(monthDate);
    const label = format(monthDate, 'yyyy-MM');

    const monthRevenue = reservations
      .filter((r) => r.check_in <= mEnd && r.check_out >= mStart)
      .reduce((sum, r) => sum + r.amount_paid, 0);

    const monthExpenses = expenses
      .filter((e) => e.date >= mStart && e.date <= mEnd)
      .reduce((sum, e) => sum + e.amount, 0);

    return {
      month: label,
      revenue: monthRevenue,
      expenses: monthExpenses,
      profit: monthRevenue - monthExpenses,
    };
  });

  // Category breakdown
  const categoryBreakdown: Record<string, number> = {};
  for (const e of expenses) {
    categoryBreakdown[e.category] = (categoryBreakdown[e.category] ?? 0) + e.amount;
  }

  // Previous year for comparison
  const prevYearStart = new Date(year - 1, 0, 1);
  const prevYearEnd = new Date(year - 1, 11, 31);

  const prevReservations = await prisma.reservation.findMany({
    where: {
      user_id: userId,
      check_in: { lte: prevYearEnd },
      check_out: { gte: prevYearStart },
      status: { not: 'cancelled' },
    },
  });
  const prevExpenses = await prisma.expense.findMany({
    where: {
      user_id: userId,
      date: { gte: prevYearStart, lte: prevYearEnd },
    },
  });

  const prevRevenue = prevReservations.reduce((sum, r) => sum + r.amount_paid, 0);
  const prevExpenseTotal = prevExpenses.reduce((sum, e) => sum + e.amount, 0);
  const prevProfit = prevRevenue - prevExpenseTotal;

  return {
    year_totals: {
      revenue: totalRevenue,
      expenses: totalExpenses,
      net_profit: totalProfit,
    },
    monthly_breakdown: monthlyBreakdown,
    category_breakdown: categoryBreakdown,
    year_over_year_changes: {
      revenue_change: percentChange(totalRevenue, prevRevenue),
      expense_change: percentChange(totalExpenses, prevExpenseTotal),
      profit_change: percentChange(totalProfit, prevProfit),
    },
  };
}
