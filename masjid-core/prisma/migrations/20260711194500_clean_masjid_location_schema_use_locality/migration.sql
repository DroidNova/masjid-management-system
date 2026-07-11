-- Clean Masjid and MasjidRegistrationRequest location schema to use locality
-- as the single API/database field for City / Village / Town.

ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "country" TEXT NOT NULL DEFAULT 'India';
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "locality" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByName" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByPhone" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByEmail" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "imamName" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "imamPhone" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "imamEmail" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "imamAddress" TEXT;
ALTER TABLE "MasjidRegistrationRequest" ADD COLUMN IF NOT EXISTS "country" TEXT NOT NULL DEFAULT 'India';
ALTER TABLE "MasjidRegistrationRequest" ADD COLUMN IF NOT EXISTS "locality" TEXT;
ALTER TABLE "MasjidRegistrationRequest" ADD COLUMN IF NOT EXISTS "imamAddress" TEXT;
ALTER TABLE "MasjidRegistrationRequest" ADD COLUMN IF NOT EXISTS "requesterName" TEXT;
ALTER TABLE "MasjidRegistrationRequest" ADD COLUMN IF NOT EXISTS "requesterPhone" TEXT;
ALTER TABLE "MasjidRegistrationRequest" ADD COLUMN IF NOT EXISTS "requesterEmail" TEXT;

UPDATE "Masjid"
SET "locality" = COALESCE(NULLIF("locality", ''), NULLIF("city", ''), NULLIF("village", ''), NULLIF("district", ''), 'Unknown locality')
WHERE "locality" IS NULL OR "locality" = '';

UPDATE "MasjidRegistrationRequest"
SET "locality" = COALESCE(NULLIF("locality", ''), NULLIF("city", ''), NULLIF("village", ''), NULLIF("district", ''), 'Unknown locality')
WHERE "locality" IS NULL OR "locality" = '';

UPDATE "Masjid" SET "state" = '' WHERE "state" IS NULL;
UPDATE "Masjid" SET "address" = 'Address pending migration' WHERE "address" IS NULL OR "address" = '';
UPDATE "Masjid" SET "requestedByName" = '' WHERE "requestedByName" IS NULL;
UPDATE "Masjid" SET "requestedByPhone" = '' WHERE "requestedByPhone" IS NULL;
ALTER TABLE "Masjid" ALTER COLUMN "requestedByName" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "requestedByPhone" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "address" SET NOT NULL;
ALTER TABLE "Masjid" ALTER COLUMN "locality" SET NOT NULL;

UPDATE "MasjidRegistrationRequest" SET "state" = '' WHERE "state" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "address" = 'Address pending migration' WHERE "address" IS NULL OR "address" = '';
UPDATE "MasjidRegistrationRequest" SET "requesterName" = '' WHERE "requesterName" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "requesterPhone" = '' WHERE "requesterPhone" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "imamAddress" = 'Address pending migration' WHERE "imamAddress" IS NULL OR "imamAddress" = '';
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "requesterName" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "requesterPhone" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "address" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "imamAddress" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "locality" SET NOT NULL;

ALTER TABLE "Masjid" DROP COLUMN IF EXISTS "village";
ALTER TABLE "Masjid" DROP COLUMN IF EXISTS "city";
ALTER TABLE "Masjid" DROP COLUMN IF EXISTS "town";
ALTER TABLE "MasjidRegistrationRequest" DROP COLUMN IF EXISTS "village";
ALTER TABLE "MasjidRegistrationRequest" DROP COLUMN IF EXISTS "city";
ALTER TABLE "MasjidRegistrationRequest" DROP COLUMN IF EXISTS "town";
