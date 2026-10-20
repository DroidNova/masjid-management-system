-- Public masjid pages: a short code per masjid, and announcements that may
-- also be shown outside the masjid. Every existing announcement stays
-- members only (isPublic false), so nothing becomes public by itself.

-- AlterTable
ALTER TABLE "Announcement" ADD COLUMN     "isPublic" BOOLEAN NOT NULL DEFAULT false;

-- AlterTable: add the code, give every existing masjid one, then require it.
-- Same alphabet as src/common/masjid-code.ts (no 0/O, 1/I/L).
ALTER TABLE "Masjid" ADD COLUMN     "publicCode" TEXT;

DO $$
DECLARE
  masjid RECORD;
  code TEXT;
  alphabet CONSTANT TEXT := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
BEGIN
  FOR masjid IN SELECT id FROM "Masjid" WHERE "publicCode" IS NULL LOOP
    LOOP
      code := '';
      FOR i IN 1..6 LOOP
        code := code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
      END LOOP;
      EXIT WHEN NOT EXISTS (SELECT 1 FROM "Masjid" WHERE "publicCode" = code);
    END LOOP;
    UPDATE "Masjid" SET "publicCode" = code WHERE id = masjid.id;
  END LOOP;
END $$;

ALTER TABLE "Masjid" ALTER COLUMN "publicCode" SET NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Masjid_publicCode_key" ON "Masjid"("publicCode");

-- CreateIndex
CREATE INDEX "Announcement_masjidId_isPublic_isActive_createdAt_idx" ON "Announcement"("masjidId", "isPublic", "isActive", "createdAt");
