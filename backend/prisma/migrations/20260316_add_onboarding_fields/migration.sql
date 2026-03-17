-- Add property and onboarding fields to users table
ALTER TABLE "users" ADD COLUMN "property_name" TEXT;
ALTER TABLE "users" ADD COLUMN "property_address" TEXT;
ALTER TABLE "users" ADD COLUMN "property_type" TEXT;
ALTER TABLE "users" ADD COLUMN "onboarding_completed" BOOLEAN NOT NULL DEFAULT false;

-- Mark existing users as having completed onboarding (they are already active)
UPDATE "users" SET "onboarding_completed" = true;
