-- Add requester tracking and country fields without creating requester users.
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "country" TEXT NOT NULL DEFAULT 'India';
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByName" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByPhone" TEXT;
ALTER TABLE "Masjid" ADD COLUMN IF NOT EXISTS "requestedByEmail" TEXT;
ALTER TABLE "Masjid" ALTER COLUMN "createdById" DROP NOT NULL;

ALTER TABLE "MasjidRegistrationRequest" ADD COLUMN IF NOT EXISTS "country" TEXT NOT NULL DEFAULT 'India';
UPDATE "MasjidRegistrationRequest" SET "state" = '' WHERE "state" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "address" = '' WHERE "address" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "requesterName" = '' WHERE "requesterName" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "requesterPhone" = '' WHERE "requesterPhone" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "imamName" = '' WHERE "imamName" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "imamPhone" = '' WHERE "imamPhone" IS NULL;
UPDATE "MasjidRegistrationRequest" SET "committeeMembers" = '[]'::jsonb WHERE "committeeMembers" IS NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "state" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "address" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "requesterName" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "requesterPhone" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "imamName" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "imamPhone" SET NOT NULL;
ALTER TABLE "MasjidRegistrationRequest" ALTER COLUMN "committeeMembers" SET NOT NULL;
