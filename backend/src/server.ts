import app from './app.js';
import { env } from './config/env.js';
import prisma from './config/db.js';
import { startRecurringExpensesJob } from './jobs/recurring-expenses.job.js';
import { startNotificationSchedulerJob } from './jobs/notification-scheduler.job.js';

const server = app.listen(env.PORT, () => {
  console.log(
    `[server] Studio Rental API running on port ${env.PORT} (${env.NODE_ENV})`,
  );
  startRecurringExpensesJob();
  startNotificationSchedulerJob();
});

process.on('SIGTERM', async () => {
  console.log('[server] SIGTERM received, shutting down gracefully...');
  server.close();
  await prisma.$disconnect();
  process.exit(0);
});
