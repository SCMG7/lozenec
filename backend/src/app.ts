import express, { type ErrorRequestHandler } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import { errorHandler } from './middleware/errorHandler.js';

import authRoutes from './modules/auth/auth.routes.js';
import reservationsRoutes from './modules/reservations/reservations.routes.js';
import guestsRoutes from './modules/guests/guests.routes.js';
import expensesRoutes from './modules/expenses/expenses.routes.js';
import analyticsRoutes from './modules/analytics/analytics.routes.js';
import notificationsRoutes from './modules/notifications/notifications.routes.js';
import dashboardRoutes from './modules/dashboard/dashboard.routes.js';
import dataRoutes from './modules/data/data.routes.js';

const app = express();

// Global middleware
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || '*',
  credentials: true,
}));
app.use(helmet());
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
app.use(express.json());

// Health check
app.get('/api/v1/health', (_req, res) => {
  res.json({ data: { status: 'ok', timestamp: new Date().toISOString() } });
});

// API routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/dashboard', dashboardRoutes);
app.use('/api/v1/reservations', reservationsRoutes);
app.use('/api/v1/guests', guestsRoutes);
app.use('/api/v1/expenses', expensesRoutes);
app.use('/api/v1/analytics', analyticsRoutes);
app.use('/api/v1/notifications', notificationsRoutes);
app.use('/api/v1/data', dataRoutes);

// Global error handler
app.use(errorHandler as unknown as ErrorRequestHandler);

export default app;
