-- Add lightweight audit snapshot fields directly to important records.
ALTER TABLE "User" ADD COLUMN "updatedById" UUID, ADD COLUMN "updatedByName" TEXT;

ALTER TABLE "NamazTime"
  ADD COLUMN "createdById" UUID,
  ADD COLUMN "createdByName" TEXT,
  ADD COLUMN "updatedById" UUID,
  ADD COLUMN "updatedByName" TEXT;

ALTER TABLE "ImamSalary"
  ADD COLUMN "createdById" UUID,
  ADD COLUMN "createdByName" TEXT,
  ADD COLUMN "updatedById" UUID,
  ADD COLUMN "updatedByName" TEXT;

ALTER TABLE "Project"
  ADD COLUMN "createdById" UUID,
  ADD COLUMN "createdByName" TEXT,
  ADD COLUMN "updatedById" UUID,
  ADD COLUMN "updatedByName" TEXT;

ALTER TABLE "Announcement"
  ADD COLUMN "createdById" UUID,
  ADD COLUMN "createdByName" TEXT,
  ADD COLUMN "updatedById" UUID,
  ADD COLUMN "updatedByName" TEXT;

ALTER TABLE "Collection"
  ADD COLUMN "createdByName" TEXT,
  ADD COLUMN "updatedById" UUID,
  ADD COLUMN "updatedByName" TEXT;

ALTER TABLE "Expense"
  ADD COLUMN "createdByName" TEXT,
  ADD COLUMN "updatedById" UUID,
  ADD COLUMN "updatedByName" TEXT;
