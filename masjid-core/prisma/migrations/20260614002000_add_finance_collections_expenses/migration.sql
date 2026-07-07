-- CreateEnum
CREATE TYPE "CollectionType" AS ENUM ('JUMMA_COLLECTION', 'DONATION_BOX', 'RAMADAN_FUND', 'ZAKAT', 'SADAQAH', 'CONSTRUCTION_FUND', 'OTHER');

-- CreateEnum
CREATE TYPE "ExpenseType" AS ENUM ('ELECTRICITY_BILL', 'WATER_BILL', 'IMAM_SALARY', 'CLEANING', 'REPAIR', 'CONSTRUCTION', 'OTHER');

-- CreateEnum
CREATE TYPE "FinanceEntryStatus" AS ENUM ('ACTIVE', 'CANCELLED');

-- CreateTable
CREATE TABLE "Collection" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "type" "CollectionType" NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "title" TEXT,
    "description" TEXT,
    "collectedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "FinanceEntryStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Collection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Expense" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "type" "ExpenseType" NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "title" TEXT,
    "description" TEXT,
    "spentAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "FinanceEntryStatus" NOT NULL DEFAULT 'ACTIVE',
    "createdById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Expense_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "Collection_masjidId_idx" ON "Collection"("masjidId");
CREATE INDEX "Collection_type_idx" ON "Collection"("type");
CREATE INDEX "Collection_status_idx" ON "Collection"("status");
CREATE INDEX "Collection_collectedAt_idx" ON "Collection"("collectedAt");
CREATE INDEX "Collection_createdById_idx" ON "Collection"("createdById");

-- CreateIndex
CREATE INDEX "Expense_masjidId_idx" ON "Expense"("masjidId");
CREATE INDEX "Expense_type_idx" ON "Expense"("type");
CREATE INDEX "Expense_status_idx" ON "Expense"("status");
CREATE INDEX "Expense_spentAt_idx" ON "Expense"("spentAt");
CREATE INDEX "Expense_createdById_idx" ON "Expense"("createdById");

-- AddForeignKey
ALTER TABLE "Collection" ADD CONSTRAINT "Collection_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Collection" ADD CONSTRAINT "Collection_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
