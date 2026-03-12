-- UpdateExpenseCategory enum: remove 'insurance' and 'marketing', add 'furniture' and 'appliances'

-- Step 1: Convert existing rows with old categories to 'other'
UPDATE "expenses" SET "category" = 'other' WHERE "category" IN ('insurance', 'marketing');

-- Step 2: Create new enum type
CREATE TYPE "ExpenseCategory_new" AS ENUM ('cleaning', 'maintenance', 'utilities', 'supplies', 'furniture', 'appliances', 'taxes', 'other');

-- Step 3: Alter column to use new enum
ALTER TABLE "expenses" ALTER COLUMN "category" TYPE "ExpenseCategory_new" USING ("category"::text::"ExpenseCategory_new");

-- Step 4: Drop old enum and rename new one
DROP TYPE "ExpenseCategory";
ALTER TYPE "ExpenseCategory_new" RENAME TO "ExpenseCategory";
