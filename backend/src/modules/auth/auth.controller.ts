import type { Request, Response } from 'express';
import { z } from 'zod';
import { asyncHandler } from '../../utils/asyncHandler.js';
import * as authService from './auth.service.js';

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
  full_name: z.string().min(1),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

const forgotPasswordSchema = z.object({
  email: z.string().email(),
});

const changePasswordSchema = z.object({
  current_password: z.string().min(1),
  new_password: z.string().min(6),
});

const updateProfileSchema = z.object({
  full_name: z.string().min(1).optional(),
  email: z.string().email().optional(),
});

const updateSettingsSchema = z.object({
  default_price_per_night: z.number().int().min(0).optional(),
  currency: z.string().optional(),
  language: z.string().optional(),
  check_in_time: z.string().optional(),
  check_out_time: z.string().optional(),
  notifications_enabled: z.boolean().optional(),
  notify_check_in: z.boolean().optional(),
  notify_check_out: z.boolean().optional(),
  notify_payment_due: z.boolean().optional(),
});

export const register = asyncHandler(async (req: Request, res: Response) => {
  const body = registerSchema.parse(req.body);
  const result = await authService.createUser(
    body.email,
    body.password,
    body.full_name,
  );
  res.status(201).json({ data: result, message: 'Registration successful' });
});

export const login = asyncHandler(async (req: Request, res: Response) => {
  const body = loginSchema.parse(req.body);
  const result = await authService.loginUser(body.email, body.password);
  res.json({ data: result, message: 'Login successful' });
});

export const verifyToken = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user!.id;
  const result = await authService.getUserById(userId);
  res.json({ data: result });
});

export const forgotPassword = asyncHandler(
  async (req: Request, res: Response) => {
    const body = forgotPasswordSchema.parse(req.body);
    const result = await authService.forgotPassword(body.email);
    res.json({ data: result });
  },
);

export const changePassword = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const body = changePasswordSchema.parse(req.body);
    const result = await authService.changePassword(
      userId,
      body.current_password,
      body.new_password,
    );
    res.json({ data: result });
  },
);

export const updateProfile = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const body = updateProfileSchema.parse(req.body);
    const result = await authService.updateProfile(userId, body);
    res.json({ data: result, message: 'Profile updated' });
  },
);

export const updateSettings = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user!.id;
    const body = updateSettingsSchema.parse(req.body);
    const result = await authService.updateSettings(userId, body);
    res.json({ data: result, message: 'Settings updated' });
  },
);

export const logout = asyncHandler(async (_req: Request, res: Response) => {
  res.json({ data: null, message: 'Logged out successfully' });
});
