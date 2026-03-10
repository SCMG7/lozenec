import prisma from '../../config/db.js';
import { ApiError } from '../../utils/ApiError.js';
import { getMonthRange } from '../../utils/dateHelpers.js';
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
