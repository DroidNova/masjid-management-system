-- Safe development migration for public masjid request approvals without auto-created users.
-- Existing nulls are backfilled before columns are made required.

ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "country" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByName" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByPhone" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByEmail" TEXT;

UPDATE "Masjid" SET "state" = COALESCE(NULLIF("state", ''), 'Unknown');
UPDATE "Masjid" SET "address" = COALESCE(NULLIF("address", ''), 'Unknown');
UPDATE "Masjid" SET "country" = COALESCE(NULLIF("country", ''), 'India');
UPDATE "Masjid" SET "requestedByName" = COALESCE(NULLIF("requestedByName", ''), 'Unknown requester');
UPDATE "Masjid" SET "requestedByPhone" = COALESCE(NULLIF("requestedByPhone", ''), '0000000000');

ALTER TABLE "Masjid" ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "address" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "country" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "requestedByName" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "requestedByPhone" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "createdById" DROP NOT NULL;

ALTER TABLE "MasjidRegistrationRequest" ADD COLUMN IF NOT EXISTS "country" TEXT;

UPDATE "MasjidRegistrationRequest" SET "requesterName" = COALESCE(NULLIF("requesterName", ''), 'Unknown requester');
UPDATE "MasjidRegistrationRequest" SET "requesterPhone" = COALESCE(NULLIF("requesterPhone", ''), '0000000000');
UPDATE "MasjidRegistrationRequest" SET "state" = COALESCE(NULLIF("state", ''), 'Unknown');
UPDATE "MasjidRegistrationRequest" SET "address" = COALESCE(NULLIF("address", ''), 'Unknown');
UPDATE "MasjidRegistrationRequest" SET "country" = COALESCE(NULLIF("country", ''), 'India');

ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "requesterName" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "requesterPhone" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "address" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "country" SET NOT NULL;
