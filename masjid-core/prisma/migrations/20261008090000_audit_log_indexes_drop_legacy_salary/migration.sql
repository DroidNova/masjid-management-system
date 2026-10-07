-- DropForeignKey
ALTER TABLE "ImamSalary" DROP CONSTRAINT "ImamSalary_masjidId_fkey";

-- DropForeignKey
ALTER TABLE "ImamSalary" DROP CONSTRAINT "ImamSalary_imamId_fkey";

-- DropTable
DROP TABLE "ImamSalary";

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" UUID NOT NULL,
    "masjidId" UUID,
    "actorId" UUID,
    "actorName" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "entity" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "summary" TEXT NOT NULL,
    "before" JSONB,
    "after" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "AuditLog_masjidId_createdAt_idx" ON "AuditLog"("masjidId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_entity_entityId_idx" ON "AuditLog"("entity", "entityId");

-- CreateIndex
CREATE INDEX "MasjidRegistrationRequest_requesterPhone_idx" ON "MasjidRegistrationRequest"("requesterPhone");

-- CreateIndex
CREATE INDEX "ProjectContribution_projectId_paidAt_idx" ON "ProjectContribution"("projectId", "paidAt");

-- CreateIndex
CREATE INDEX "CollectionContribution_masjidId_paidAt_idx" ON "CollectionContribution"("masjidId", "paidAt");

-- CreateIndex
CREATE INDEX "Announcement_masjidId_isActive_createdAt_idx" ON "Announcement"("masjidId", "isActive", "createdAt");

-- CreateIndex
CREATE INDEX "Collection_masjidId_status_collectedAt_idx" ON "Collection"("masjidId", "status", "collectedAt");

-- CreateIndex
CREATE INDEX "Expense_masjidId_status_spentAt_idx" ON "Expense"("masjidId", "status", "spentAt");

