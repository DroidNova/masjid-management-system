-- DropIndex
DROP INDEX "UserRole_userId_idx";

-- DropIndex
DROP INDEX "Masjid_status_idx";

-- DropIndex
DROP INDEX "MasjidRegistrationRequest_status_idx";

-- DropIndex
DROP INDEX "ImamSalaryPayment_paymentMode_idx";

-- DropIndex
DROP INDEX "Project_masjidId_idx";

-- DropIndex
DROP INDEX "Project_status_idx";

-- DropIndex
DROP INDEX "ProjectContribution_masjidId_idx";

-- DropIndex
DROP INDEX "ProjectContribution_projectId_idx";

-- DropIndex
DROP INDEX "ProjectContribution_paymentMode_idx";

-- DropIndex
DROP INDEX "CollectionContribution_paymentMode_idx";

-- DropIndex
DROP INDEX "Announcement_masjidId_idx";

-- DropIndex
DROP INDEX "Announcement_isActive_idx";

-- DropIndex
DROP INDEX "Collection_masjidId_idx";

-- DropIndex
DROP INDEX "Collection_type_idx";

-- DropIndex
DROP INDEX "Collection_status_idx";

-- DropIndex
DROP INDEX "Expense_masjidId_idx";

-- DropIndex
DROP INDEX "Expense_type_idx";

-- DropIndex
DROP INDEX "Expense_status_idx";

-- AlterTable
ALTER TABLE "CollectionContribution" ADD COLUMN     "collectionId" UUID;

-- CreateIndex
CREATE INDEX "User_createdAt_idx" ON "User"("createdAt");

-- CreateIndex
CREATE INDEX "User_status_idx" ON "User"("status");

-- CreateIndex
CREATE INDEX "Masjid_status_createdAt_idx" ON "Masjid"("status", "createdAt");

-- CreateIndex
CREATE INDEX "MasjidRegistrationRequest_status_createdAt_idx" ON "MasjidRegistrationRequest"("status", "createdAt");

-- CreateIndex
CREATE INDEX "MasjidRegistrationRequest_createdAt_idx" ON "MasjidRegistrationRequest"("createdAt");

-- CreateIndex
CREATE INDEX "ImamSalaryPayment_masjidId_paidAt_idx" ON "ImamSalaryPayment"("masjidId", "paidAt");

-- CreateIndex
CREATE INDEX "Project_masjidId_status_createdAt_idx" ON "Project"("masjidId", "status", "createdAt");

-- CreateIndex
CREATE INDEX "ProjectContribution_masjidId_paidAt_idx" ON "ProjectContribution"("masjidId", "paidAt");

-- CreateIndex
CREATE UNIQUE INDEX "CollectionContribution_collectionId_key" ON "CollectionContribution"("collectionId");

-- CreateIndex
CREATE INDEX "Announcement_masjidId_createdAt_idx" ON "Announcement"("masjidId", "createdAt");

-- CreateIndex
CREATE INDEX "Collection_masjidId_collectedAt_idx" ON "Collection"("masjidId", "collectedAt");

-- CreateIndex
CREATE INDEX "Expense_masjidId_spentAt_idx" ON "Expense"("masjidId", "spentAt");

-- CreateIndex
CREATE INDEX "AuditLog_masjidId_entity_createdAt_idx" ON "AuditLog"("masjidId", "entity", "createdAt");

-- AddForeignKey
ALTER TABLE "CollectionContribution" ADD CONSTRAINT "CollectionContribution_collectionId_fkey" FOREIGN KEY ("collectionId") REFERENCES "Collection"("id") ON DELETE SET NULL ON UPDATE CASCADE;

