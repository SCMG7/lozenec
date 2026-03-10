import type { Request, Response } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../../utils/asyncHandler.js';
import * as expensesService from './expenses.service.js';

const createExpenseSchema = z.object({
  category: z.enum([
    'cleaning',
    'maintenance',
    'utilities',
    'supplies',
    'insurance',
    'taxes',
    'marketing',
    'other',
  ]),
  amount: z.number().int().min(1),
  description: z.string().nullable().optional(),
  date: z.string(),
});

const updateExpenseSchema = createExpenseSchema.partial();

export const list = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const month = req.query['month'] as string | undefined;
  const category = req.query['category'] as string | undefined;
  const data = await expensesService.listExpenses(userId, month, category);
  res.json({ data });
});

export const getById = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await expensesService.getExpenseById(userId, req.params['id'] as string);
  res.json({ data });
});

export const create = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = createExpenseSchema.parse(req.body);
  const data = await expensesService.createExpense(userId, body);
  res.status(201).json({ data, message: 'Expense created' });
});

export const update = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const body = updateExpenseSchema.parse(req.body);
  const data = await expensesService.updateExpense(
    userId,
    req.params['id'] as string,
    body,
  );
  res.json({ data, message: 'Expense updated' });
});

export const remove = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await expensesService.deleteExpense(userId, req.params['id'] as string);
  res.json({ data });
});
