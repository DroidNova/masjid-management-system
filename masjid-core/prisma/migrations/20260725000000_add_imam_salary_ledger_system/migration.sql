CREATE TYPE "ImamSalaryAssignmentStatus" AS ENUM ('UNPAID', 'PARTIAL', 'PAID');
CREATE TYPE "PaymentMode" AS ENUM ('CASH', 'ONLINE');

CREATE TABLE "ImamSalaryMonth" ("id" UUID NOT NULL, "masjidId" UUID NOT NULL, "month" INTEGER NOT NULL, "year" INTEGER NOT NULL, "amountPerHead" DECIMAL(12,2) NOT NULL, "totalExpected" DECIMAL(12,2) NOT NULL DEFAULT 0, "totalCollected" DECIMAL(12,2) NOT NULL DEFAULT 0, "totalDue" DECIMAL(12,2) NOT NULL DEFAULT 0, "paidCount" INTEGER NOT NULL DEFAULT 0, "partialCount" INTEGER NOT NULL DEFAULT 0, "unpaidCount" INTEGER NOT NULL DEFAULT 0, "status" "PaymentStatus" NOT NULL DEFAULT 'UNPAID', "note" TEXT, "createdById" UUID, "createdByName" TEXT, "updatedById" UUID, "updatedByName" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL, CONSTRAINT "ImamSalaryMonth_pkey" PRIMARY KEY ("id"));
CREATE TABLE "ImamSalaryAssignment" ("id" UUID NOT NULL, "masjidId" UUID NOT NULL, "imamSalaryMonthId" UUID NOT NULL, "memberId" UUID NOT NULL, "memberName" TEXT NOT NULL, "memberPhone" TEXT NOT NULL, "expectedAmount" DECIMAL(12,2) NOT NULL, "paidAmount" DECIMAL(12,2) NOT NULL DEFAULT 0, "dueAmount" DECIMAL(12,2) NOT NULL, "status" "ImamSalaryAssignmentStatus" NOT NULL DEFAULT 'UNPAID', "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL, CONSTRAINT "ImamSalaryAssignment_pkey" PRIMARY KEY ("id"));
CREATE TABLE "ImamSalaryPayment" ("id" UUID NOT NULL, "masjidId" UUID NOT NULL, "imamSalaryMonthId" UUID NOT NULL, "assignmentId" UUID NOT NULL, "memberId" UUID NOT NULL, "memberName" TEXT NOT NULL, "memberPhone" TEXT NOT NULL, "amount" DECIMAL(12,2) NOT NULL, "paymentMode" "PaymentMode" NOT NULL, "paymentForMonth" INTEGER NOT NULL, "paymentForYear" INTEGER NOT NULL, "paidAt" TIMESTAMP(3) NOT NULL, "collectedById" UUID NOT NULL, "collectedByName" TEXT NOT NULL, "note" TEXT, "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP, "updatedAt" TIMESTAMP(3) NOT NULL, CONSTRAINT "ImamSalaryPayment_pkey" PRIMARY KEY ("id"));

CREATE UNIQUE INDEX "ImamSalaryMonth_masjidId_month_year_key" ON "ImamSalaryMonth"("masjidId", "month", "year");
CREATE INDEX "ImamSalaryMonth_masjidId_year_month_idx" ON "ImamSalaryMonth"("masjidId", "year", "month");
CREATE UNIQUE INDEX "ImamSalaryAssignment_imamSalaryMonthId_memberId_key" ON "ImamSalaryAssignment"("imamSalaryMonthId", "memberId");
CREATE INDEX "ImamSalaryAssignment_masjidId_status_idx" ON "ImamSalaryAssignment"("masjidId", "status");
CREATE INDEX "ImamSalaryAssignment_memberId_idx" ON "ImamSalaryAssignment"("memberId");
CREATE INDEX "ImamSalaryPayment_masjidId_paymentForYear_paymentForMonth_idx" ON "ImamSalaryPayment"("masjidId", "paymentForYear", "paymentForMonth");
CREATE INDEX "ImamSalaryPayment_memberId_idx" ON "ImamSalaryPayment"("memberId");
CREATE INDEX "ImamSalaryPayment_paidAt_idx" ON "ImamSalaryPayment"("paidAt");
CREATE INDEX "ImamSalaryPayment_paymentMode_idx" ON "ImamSalaryPayment"("paymentMode");
CREATE INDEX "ImamSalaryPayment_collectedById_idx" ON "ImamSalaryPayment"("collectedById");

ALTER TABLE "ImamSalaryMonth" ADD CONSTRAINT "ImamSalaryMonth_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ImamSalaryAssignment" ADD CONSTRAINT "ImamSalaryAssignment_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ImamSalaryAssignment" ADD CONSTRAINT "ImamSalaryAssignment_imamSalaryMonthId_fkey" FOREIGN KEY ("imamSalaryMonthId") REFERENCES "ImamSalaryMonth"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ImamSalaryAssignment" ADD CONSTRAINT "ImamSalaryAssignment_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_imamSalaryMonthId_fkey" FOREIGN KEY ("imamSalaryMonthId") REFERENCES "ImamSalaryMonth"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "ImamSalaryAssignment"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_collectedById_fkey" FOREIGN KEY ("collectedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
