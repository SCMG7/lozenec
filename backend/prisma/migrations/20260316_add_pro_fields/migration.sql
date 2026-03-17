-- AlterTable
ALTER TABLE "users" ADD COLUMN "pro_expires_at" TIMESTAMP(3);
ALTER TABLE "users" ADD COLUMN "has_lifetime_tax_report" BOOLEAN NOT NULL DEFAULT false;
