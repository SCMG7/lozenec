import dotenv from 'dotenv';
dotenv.config();

function requireEnv(key: string, defaultValue?: string): string {
  const value = process.env[key] ?? defaultValue;
  if (value === undefined) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value;
}

function optionalEnv(key: string): string | undefined {
  return process.env[key] || undefined;
}

export const env = {
  DATABASE_URL: requireEnv('DATABASE_URL'),
  JWT_SECRET: requireEnv('JWT_SECRET'),
  JWT_EXPIRES_IN: requireEnv('JWT_EXPIRES_IN', '7d'),
  PORT: parseInt(requireEnv('PORT', '3000'), 10),
  NODE_ENV: requireEnv('NODE_ENV', 'development'),
  CLOUDINARY_CLOUD_NAME: optionalEnv('CLOUDINARY_CLOUD_NAME') ?? '',
  CLOUDINARY_API_KEY: optionalEnv('CLOUDINARY_API_KEY') ?? '',
  CLOUDINARY_API_SECRET: optionalEnv('CLOUDINARY_API_SECRET') ?? '',
} as const;
