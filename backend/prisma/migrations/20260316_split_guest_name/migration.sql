-- Add first_name and last_name columns to guests table
ALTER TABLE "guests" ADD COLUMN "first_name" TEXT;
ALTER TABLE "guests" ADD COLUMN "last_name" TEXT;

-- Split existing full_name into first_name and last_name
-- Uses first space as delimiter; everything before = first_name, everything after = last_name
UPDATE "guests"
SET
  "first_name" = CASE
    WHEN POSITION(' ' IN "full_name") > 0 THEN SUBSTRING("full_name" FROM 1 FOR POSITION(' ' IN "full_name") - 1)
    ELSE "full_name"
  END,
  "last_name" = CASE
    WHEN POSITION(' ' IN "full_name") > 0 THEN SUBSTRING("full_name" FROM POSITION(' ' IN "full_name") + 1)
    ELSE ''
  END;

-- Now make first_name NOT NULL with default empty string for safety
ALTER TABLE "guests" ALTER COLUMN "first_name" SET NOT NULL;
ALTER TABLE "guests" ALTER COLUMN "first_name" SET DEFAULT '';
ALTER TABLE "guests" ALTER COLUMN "last_name" SET NOT NULL;
ALTER TABLE "guests" ALTER COLUMN "last_name" SET DEFAULT '';
