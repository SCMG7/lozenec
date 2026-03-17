import cron from 'node-cron';
import prisma from '../config/db.js';
import { addMonths, addYears, isSameDay } from 'date-fns';

/**
 * Runs daily at 08:00 to auto-create recurring expense instances when they're due.
 */
export function startRecurringExpensesJob() {
  // Run at 08:00 every day
  cron.schedule('0 8 * * *', async () => {
    console.log('[RecurringExpenses] Running recurring expense check...');
    try {
      await processRecurringExpenses();
    } catch (error) {
      console.error('[RecurringExpenses] Error processing recurring expenses:', error);
    }
  });
  console.log('[RecurringExpenses] Cron job scheduled (daily at 08:00)');
}

export async function processRecurringExpenses() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  // Find all recurring parent expenses (not auto-generated ones)
  const recurringExpenses = await prisma.expense.findMany({
    where: {
      is_recurring: true,
      parent_expense_id: null, // Only originals, not generated copies
    },
  });

  let created = 0;
  for (const expense of recurringExpenses) {
    const frequency = expense.recurrence_frequency;
    if (!frequency) continue;

    // Find the most recent instance of this recurring expense
    const lastInstance = await prisma.expense.findFirst({
      where: {
        OR: [
          { id: expense.id },
          { parent_expense_id: expense.id },
        ],
      },
      orderBy: { date: 'desc' },
    });

    if (!lastInstance) continue;

    // QA FIX: Use while-loop to catch up all missed instances after server downtime
    let lastDate = lastInstance.date;
    let nextDueDate: Date;

    // eslint-disable-next-line no-constant-condition
    while (true) {
      if (frequency === 'monthly') {
        nextDueDate = addMonths(lastDate, 1);
      } else if (frequency === 'yearly') {
        nextDueDate = addYears(lastDate, 1);
      } else {
        break;
      }

      if (nextDueDate > today) break;

      await prisma.expense.create({
        data: {
          user_id: expense.user_id,
          category: expense.category,
          amount: expense.amount,
          description: expense.description,
          date: nextDueDate,
          is_recurring: false, // Auto-generated instances are not themselves recurring
          parent_expense_id: expense.id,
        },
      });
      created++;
      lastDate = nextDueDate;
    }
  }

  if (created > 0) {
    console.log(`[RecurringExpenses] Created ${created} recurring expense instances`);
  }
}
