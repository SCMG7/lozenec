-- Add recurring expense fields
ALTER TABLE "expenses" ADD COLUMN "is_recurring" BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE "expenses" ADD COLUMN "recurrence_frequency" TEXT;
ALTER TABLE "expenses" ADD COLUMN "parent_expense_id" UUID;

-- Add self-referential FK for parent expense
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_parent_expense_id_fkey"
  FOREIGN KEY ("parent_expense_id") REFERENCES "expenses"("id") ON DELETE SET NULL ON UPDATE CASCADE;
