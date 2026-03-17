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
    'furniture',
    'appliances',
    'taxes',
    'other',
  ]),
  amount: z.number().int().min(1),
  description: z.string().nullable().optional(),
  date: z.string(),
  property_id: z.string().uuid().nullable().optional(),
  is_recurring: z.boolean().optional(),
  recurrence_frequency: z.enum(['monthly', 'yearly']).nullable().optional(),
});

const updateExpenseSchema = createExpenseSchema.partial();

export const list = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const month = req.query['month'] as string | undefined;
  const category = req.query['category'] as string | undefined;
  const propertyId = req.query['property_id'] as string | undefined;
  const data = await expensesService.listExpenses(userId, month, category, propertyId);
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

export const uploadReceipt = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const file = req.file;
  if (!file) {
    res.status(400).json({ error: 'No file uploaded' });
    return;
  }
  const data = await expensesService.uploadReceipt(userId, req.params['id'] as string, file.buffer);
  res.json({ data, message: 'Receipt uploaded' });
});

export const deleteReceipt = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const data = await expensesService.deleteReceipt(userId, req.params['id'] as string);
  res.json({ data, message: 'Receipt deleted' });
});

export const getSummary = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const month = req.query['month'] as string | undefined;
  if (!month || !/^\d{4}-\d{2}$/.test(month)) {
    res.status(400).json({ error: 'month query parameter required (YYYY-MM)' });
    return;
  }
  const data = await expensesService.getFinancialSummary(userId, month);
  res.json({ data });
});

export const getAnnualSummary = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const yearStr = req.query['year'] as string | undefined;
  if (!yearStr || !/^\d{4}$/.test(yearStr)) {
    res.status(400).json({ error: 'year query parameter required (YYYY)' });
    return;
  }
  const data = await expensesService.getAnnualSummary(userId, parseInt(yearStr, 10));
  res.json({ data });
});
