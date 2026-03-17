-- CreateTable
CREATE TABLE "properties" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT,
    "property_type" TEXT,
    "default_price_per_night" INTEGER NOT NULL DEFAULT 0,
    "check_in_time" TEXT NOT NULL DEFAULT '14:00',
    "check_out_time" TEXT NOT NULL DEFAULT '12:00',
    "currency" TEXT NOT NULL DEFAULT 'EUR',
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "properties_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "properties_user_id_idx" ON "properties"("user_id");

-- AddForeignKey
ALTER TABLE "properties" ADD CONSTRAINT "properties_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Add property_id columns (nullable for backwards compatibility)
ALTER TABLE "reservations" ADD COLUMN "property_id" UUID;
ALTER TABLE "expenses" ADD COLUMN "property_id" UUID;
ALTER TABLE "notifications" ADD COLUMN "property_id" UUID;

-- Create indexes on property_id
CREATE INDEX "reservations_property_id_idx" ON "reservations"("property_id");
CREATE INDEX "expenses_property_id_idx" ON "expenses"("property_id");
CREATE INDEX "notifications_property_id_idx" ON "notifications"("property_id");

-- For each existing user, create a default property from their user-level settings
INSERT INTO "properties" ("id", "user_id", "name", "address", "property_type", "default_price_per_night", "check_in_time", "check_out_time", "currency", "is_active", "created_at", "updated_at")
SELECT
    gen_random_uuid(),
    u."id",
    COALESCE(u."property_name", 'My Property'),
    u."property_address",
    u."property_type",
    u."default_price_per_night",
    u."check_in_time",
    u."check_out_time",
    u."currency",
    true,
    NOW(),
    NOW()
FROM "users" u;

-- Update all existing reservations to point to the user's default property
UPDATE "reservations" r
SET "property_id" = p."id"
FROM "properties" p
WHERE r."user_id" = p."user_id";

-- Update all existing expenses to point to the user's default property
UPDATE "expenses" e
SET "property_id" = p."id"
FROM "properties" p
WHERE e."user_id" = p."user_id";

-- Update all existing notifications to point to the user's default property
UPDATE "notifications" n
SET "property_id" = p."id"
FROM "properties" p
WHERE n."user_id" = p."user_id";

-- Add foreign key constraints
ALTER TABLE "reservations" ADD CONSTRAINT "reservations_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "expenses" ADD CONSTRAINT "expenses_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_property_id_fkey" FOREIGN KEY ("property_id") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;
