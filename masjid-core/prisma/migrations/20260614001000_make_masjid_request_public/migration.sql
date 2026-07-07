-- Allow public masjid request submissions without a user account.

ALTER TABLE IF EXISTS "MasjidRegistrationRequest"
  ADD COLUMN IF NOT EXISTS "requesterName" TEXT,
  ADD COLUMN IF NOT EXISTS "requesterPhone" TEXT,
  ADD COLUMN IF NOT EXISTS "requesterEmail" TEXT;

ALTER TABLE IF EXISTS "MasjidRegistrationRequest"
  ALTER COLUMN "requestedById" DROP NOT NULL;
