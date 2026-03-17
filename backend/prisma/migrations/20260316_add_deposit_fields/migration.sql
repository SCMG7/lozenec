-- Add deposit fields to reservations table
ALTER TABLE "reservations" ADD COLUMN "deposit_amount" INTEGER;
ALTER TABLE "reservations" ADD COLUMN "deposit_received" BOOLEAN NOT NULL DEFAULT false;
