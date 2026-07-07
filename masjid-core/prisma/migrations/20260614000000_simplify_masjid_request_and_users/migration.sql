-- Simplify masjid membership for development databases.
-- If a previous MasjidUser join table exists, copy one active masjid link per user
-- into User.masjidId before dropping the join table.

ALTER TABLE "User" ADD COLUMN IF NOT EXISTS "masjidId" UUID;

DO $$
BEGIN
  IF to_regclass('"MasjidUser"') IS NOT NULL THEN
    EXECUTE '
      UPDATE "User" AS u
      SET "masjidId" = mu."masjidId"
      FROM (
        SELECT DISTINCT ON ("userId") "userId", "masjidId"
        FROM "MasjidUser"
        WHERE "isActive" = true
        ORDER BY "userId", "updatedAt" DESC
      ) AS mu
      WHERE u."id" = mu."userId"
        AND u."masjidId" IS NULL
    ';

    EXECUTE 'DROP TABLE "MasjidUser"';
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS "User_masjidId_idx" ON "User"("masjidId");

DO $$
BEGIN
  IF to_regclass('"Masjid"') IS NOT NULL THEN
    ALTER TABLE "User"
      ADD CONSTRAINT "User_masjidId_fkey"
      FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id")
      ON DELETE SET NULL ON UPDATE CASCADE;
  END IF;
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;
