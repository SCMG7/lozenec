import bcrypt from 'bcrypt';
import jwt, { type SignOptions } from 'jsonwebtoken';
import crypto from 'crypto';
import prisma from '../../config/db.js';
import { env } from '../../config/env.js';
import { ApiError } from '../../utils/ApiError.js';
import { sendPasswordResetEmail } from '../../services/email.service.js';

function generateToken(userId: string): string {
  const options: SignOptions = {
    expiresIn: env.JWT_EXPIRES_IN as unknown as jwt.SignOptions['expiresIn'],
  };
  return jwt.sign({ userId }, env.JWT_SECRET, options);
}

function sanitizeUser(user: {
  id: string;
  email: string;
  full_name: string;
  default_price_per_night: number;
  currency: string;
  language: string;
  check_in_time: string;
  check_out_time: string;
  property_name: string | null;
  property_address: string | null;
  property_type: string | null;
  onboarding_completed: boolean;
  notifications_enabled: boolean;
  notify_check_in: boolean;
  notify_check_out: boolean;
  notify_payment_due: boolean;
  pro_expires_at: Date | null;
  has_lifetime_tax_report: boolean;
  created_at: Date;
}) {
  return {
    id: user.id,
    email: user.email,
    full_name: user.full_name,
    default_price_per_night: user.default_price_per_night,
    currency: user.currency,
    language: user.language,
    check_in_time: user.check_in_time,
    check_out_time: user.check_out_time,
    property_name: user.property_name,
    property_address: user.property_address,
    property_type: user.property_type,
    onboarding_completed: user.onboarding_completed,
    notifications_enabled: user.notifications_enabled,
    notify_check_in: user.notify_check_in,
    notify_check_out: user.notify_check_out,
    notify_payment_due: user.notify_payment_due,
    pro_expires_at: user.pro_expires_at ? user.pro_expires_at.toISOString() : null,
    has_lifetime_tax_report: user.has_lifetime_tax_report,
    created_at: user.created_at.toISOString(),
  };
}

export async function createUser(
  email: string,
  password: string,
  fullName: string,
) {
  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    throw ApiError.conflict('A user with this email already exists');
  }

  const passwordHash = await bcrypt.hash(password, 12);
  const user = await prisma.user.create({
    data: {
      email,
      password_hash: passwordHash,
      full_name: fullName,
    },
  });

  const token = generateToken(user.id);
  return { user: sanitizeUser(user), token };
}

export async function loginUser(email: string, password: string) {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    throw ApiError.unauthorized('Invalid email or password');
  }

  const valid = await bcrypt.compare(password, user.password_hash);
  if (!valid) {
    throw ApiError.unauthorized('Invalid email or password');
  }

  const token = generateToken(user.id);
  return { user: sanitizeUser(user), token };
}

export async function verifyTokenAndGetUser(token: string) {
  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as { userId: string };
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
    });
    if (!user) {
      throw ApiError.unauthorized('User not found');
    }
    return { user: sanitizeUser(user) };
  } catch {
    throw ApiError.unauthorized('Invalid or expired token');
  }
}

export async function getUserById(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
  });
  if (!user) {
    throw ApiError.notFound('User not found');
  }
  return { user: sanitizeUser(user) };
}

export async function forgotPassword(email: string) {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    // Don't reveal if user exists
    return { message: 'If the email exists, a reset link has been sent' };
  }

  const token = crypto.randomBytes(32).toString('hex');
  const expiresAt = new Date(Date.now() + 3600000); // 1 hour

  await prisma.passwordResetToken.create({
    data: {
      user_id: user.id,
      token,
      expires_at: expiresAt,
    },
  });

  // Send the reset email (logs error internally if it fails)
  await sendPasswordResetEmail(email, token);

  return { message: 'If the email exists, a reset link has been sent' };
}

export async function changePassword(
  userId: string,
  currentPassword: string,
  newPassword: string,
) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) {
    throw ApiError.notFound('User not found');
  }

  const valid = await bcrypt.compare(currentPassword, user.password_hash);
  if (!valid) {
    throw ApiError.badRequest('Current password is incorrect');
  }

  const passwordHash = await bcrypt.hash(newPassword, 12);
  await prisma.user.update({
    where: { id: userId },
    data: { password_hash: passwordHash },
  });

  return { message: 'Password changed successfully' };
}

export async function updateProfile(
  userId: string,
  data: { full_name?: string; email?: string },
) {
  if (data.email) {
    const existing = await prisma.user.findFirst({
      where: { email: data.email, NOT: { id: userId } },
    });
    if (existing) {
      throw ApiError.conflict('Email already in use');
    }
  }

  const user = await prisma.user.update({
    where: { id: userId },
    data: {
      ...(data.full_name !== undefined && { full_name: data.full_name }),
      ...(data.email !== undefined && { email: data.email }),
    },
  });

  return { user: sanitizeUser(user) };
}

export async function upsertDeviceToken(
  userId: string,
  token: string,
  platform: string,
) {
  const existing = await prisma.deviceToken.findUnique({
    where: { token },
  });

  if (existing) {
    // Update ownership if token already exists (e.g. user re-logged in)
    if (existing.user_id !== userId) {
      await prisma.deviceToken.update({
        where: { token },
        data: { user_id: userId, platform },
      });
    }
    return { message: 'Device token registered' };
  }

  await prisma.deviceToken.create({
    data: {
      user_id: userId,
      token,
      platform,
    },
  });

  return { message: 'Device token registered' };
}

export async function resetPassword(token: string, newPassword: string) {
  const resetToken = await prisma.passwordResetToken.findUnique({
    where: { token },
  });

  if (!resetToken) {
    throw ApiError.badRequest('Invalid or expired reset token');
  }

  if (resetToken.expires_at < new Date()) {
    await prisma.passwordResetToken.delete({ where: { token } });
    throw ApiError.badRequest('Reset token has expired');
  }

  const passwordHash = await bcrypt.hash(newPassword, 12);

  await prisma.user.update({
    where: { id: resetToken.user_id },
    data: { password_hash: passwordHash },
  });

  await prisma.passwordResetToken.delete({ where: { token } });

  return { message: 'Password has been reset successfully' };
}

export async function updateSettings(
  userId: string,
  data: {
    default_price_per_night?: number;
    currency?: string;
    language?: string;
    check_in_time?: string;
    check_out_time?: string;
    property_name?: string;
    property_address?: string;
    property_type?: string;
    onboarding_completed?: boolean;
    notifications_enabled?: boolean;
    notify_check_in?: boolean;
    notify_check_out?: boolean;
    notify_payment_due?: boolean;
  },
) {
  const user = await prisma.user.update({
    where: { id: userId },
    data,
  });

  return { user: sanitizeUser(user) };
}
