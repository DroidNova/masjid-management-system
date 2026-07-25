CREATE TABLE "ProjectContribution" (
  "id" UUID NOT NULL, "masjidId" UUID NOT NULL, "projectId" UUID NOT NULL,
  "memberId" UUID, "contributorName" TEXT NOT NULL, "contributorPhone" TEXT,
  "amount" DECIMAL(12,2) NOT NULL, "paymentMode" "PaymentMode" NOT NULL,
  "paidAt" TIMESTAMP(3) NOT NULL, "collectedById" UUID NOT NULL,
  "collectedByName" TEXT NOT NULL, "note" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "ProjectContribution_pkey" PRIMARY KEY ("id")
);
CREATE TABLE "CollectionContribution" (
  "id" UUID NOT NULL, "masjidId" UUID NOT NULL, "memberId" UUID,
  "contributorName" TEXT NOT NULL, "contributorPhone" TEXT,
  "collectionType" "CollectionType" NOT NULL, "amount" DECIMAL(12,2) NOT NULL,
  "paymentMode" "PaymentMode" NOT NULL, "paidAt" TIMESTAMP(3) NOT NULL,
  "collectedById" UUID NOT NULL, "collectedByName" TEXT NOT NULL, "note" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "CollectionContribution_pkey" PRIMARY KEY ("id")
);
CREATE INDEX "ProjectContribution_masjidId_idx" ON "ProjectContribution"("masjidId");
CREATE INDEX "ProjectContribution_projectId_idx" ON "ProjectContribution"("projectId");
CREATE INDEX "ProjectContribution_memberId_idx" ON "ProjectContribution"("memberId");
CREATE INDEX "ProjectContribution_paidAt_idx" ON "ProjectContribution"("paidAt");
CREATE INDEX "ProjectContribution_paymentMode_idx" ON "ProjectContribution"("paymentMode");
CREATE INDEX "CollectionContribution_masjidId_idx" ON "CollectionContribution"("masjidId");
CREATE INDEX "CollectionContribution_memberId_idx" ON "CollectionContribution"("memberId");
CREATE INDEX "CollectionContribution_paidAt_idx" ON "CollectionContribution"("paidAt");
CREATE INDEX "CollectionContribution_collectionType_idx" ON "CollectionContribution"("collectionType");
CREATE INDEX "CollectionContribution_paymentMode_idx" ON "CollectionContribution"("paymentMode");
ALTER TABLE "ProjectContribution" ADD CONSTRAINT "ProjectContribution_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ProjectContribution" ADD CONSTRAINT "ProjectContribution_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ProjectContribution" ADD CONSTRAINT "ProjectContribution_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "ProjectContribution" ADD CONSTRAINT "ProjectContribution_collectedById_fkey" FOREIGN KEY ("collectedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "CollectionContribution" ADD CONSTRAINT "CollectionContribution_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "CollectionContribution" ADD CONSTRAINT "CollectionContribution_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE "CollectionContribution" ADD CONSTRAINT "CollectionContribution_collectedById_fkey" FOREIGN KEY ("collectedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
