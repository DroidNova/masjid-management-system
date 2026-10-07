-- CreateEnum
CREATE TYPE "UserStatus" AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "RoleName" AS ENUM ('SUPER_ADMIN', 'MASJID_ADMIN', 'IMAM', 'COMMITTEE_MEMBER', 'MEMBER');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('PAID', 'UNPAID', 'PARTIAL');

-- CreateEnum
CREATE TYPE "ImamSalaryAssignmentStatus" AS ENUM ('UNPAID', 'PARTIAL', 'PAID');

-- CreateEnum
CREATE TYPE "PaymentMode" AS ENUM ('CASH', 'ONLINE');

-- CreateEnum
CREATE TYPE "ProjectStatus" AS ENUM ('PLANNED', 'ONGOING', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "CollectionType" AS ENUM ('JUMMA_COLLECTION', 'DONATION_BOX', 'RAMADAN_FUND', 'ZAKAT', 'SADAQAH', 'CONSTRUCTION_FUND', 'OTHER');

-- CreateEnum
CREATE TYPE "ExpenseType" AS ENUM ('ELECTRICITY_BILL', 'WATER_BILL', 'IMAM_SALARY', 'CLEANING', 'REPAIR', 'CONSTRUCTION', 'OTHER');

-- CreateEnum
CREATE TYPE "FinanceEntryStatus" AS ENUM ('ACTIVE', 'CANCELLED');

-- CreateEnum
CREATE TYPE "MasjidStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED');

-- CreateEnum
CREATE TYPE "MasjidRegistrationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- CreateTable
CREATE TABLE "User" (
    "id" UUID NOT NULL,
    "fullName" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "fatherName" TEXT,
    "age" INTEGER,
    "gender" "Gender",
    "isFamilyHead" BOOLEAN NOT NULL DEFAULT false,
    "familyMemberCount" INTEGER,
    "masjidId" UUID,
    "passwordHash" TEXT NOT NULL,
    "status" "UserStatus" NOT NULL DEFAULT 'ACTIVE',
    "isEmailVerified" BOOLEAN NOT NULL DEFAULT false,
    "isPhoneVerified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Role" (
    "id" UUID NOT NULL,
    "name" "RoleName" NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Role_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Permission" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Permission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RolePermission" (
    "id" UUID NOT NULL,
    "roleId" UUID NOT NULL,
    "permissionId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "RolePermission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UserRole" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "roleId" UUID NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "UserRole_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" UUID NOT NULL,
    "userId" UUID NOT NULL,
    "refreshTokenHash" TEXT NOT NULL,
    "deviceName" TEXT,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Masjid" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "country" TEXT NOT NULL DEFAULT 'India',
    "state" TEXT NOT NULL,
    "district" TEXT,
    "locality" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "contactNo" TEXT,
    "description" TEXT,
    "welcomeMsg" TEXT,
    "status" "MasjidStatus" NOT NULL DEFAULT 'PENDING',
    "rejectionReason" TEXT,
    "approvedAt" TIMESTAMP(3),
    "requestedByName" TEXT NOT NULL,
    "requestedByPhone" TEXT NOT NULL,
    "requestedByEmail" TEXT,
    "imamName" TEXT,
    "imamPhone" TEXT,
    "imamEmail" TEXT,
    "imamAddress" TEXT,
    "createdById" UUID,
    "imamUserId" UUID,
    "approvedById" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Masjid_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MasjidRegistrationRequest" (
    "id" UUID NOT NULL,
    "requestedById" UUID,
    "reviewedById" UUID,
    "requesterName" TEXT NOT NULL,
    "requesterPhone" TEXT NOT NULL,
    "requesterEmail" TEXT,
    "status" "MasjidRegistrationStatus" NOT NULL DEFAULT 'PENDING',
    "masjidName" TEXT NOT NULL,
    "country" TEXT NOT NULL DEFAULT 'India',
    "state" TEXT NOT NULL,
    "district" TEXT,
    "locality" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "contactNo" TEXT,
    "description" TEXT,
    "welcomeMsg" TEXT,
    "imamName" TEXT NOT NULL,
    "imamEmail" TEXT,
    "imamPhone" TEXT NOT NULL,
    "imamAddress" TEXT NOT NULL,
    "imamFatherName" TEXT,
    "imamAge" INTEGER,
    "imamGender" "Gender",
    "committeeMembers" JSONB NOT NULL,
    "rejectionReason" TEXT,
    "reviewedAt" TIMESTAMP(3),
    "createdMasjidId" UUID,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MasjidRegistrationRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "NamazTime" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "fajr" TEXT,
    "zuhr" TEXT,
    "asr" TEXT,
    "maghrib" TEXT,
    "isha" TEXT,
    "jumma" TEXT,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "NamazTime_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ImamSalary" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "imamId" UUID NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "salaryAmount" DECIMAL(12,2) NOT NULL,
    "paidAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "dueAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "status" "PaymentStatus" NOT NULL DEFAULT 'UNPAID',
    "paidDate" TIMESTAMP(3),
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ImamSalary_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ImamSalaryMonth" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "month" INTEGER NOT NULL,
    "year" INTEGER NOT NULL,
    "amountPerHead" DECIMAL(12,2) NOT NULL,
    "totalExpected" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "totalCollected" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "totalDue" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "paidCount" INTEGER NOT NULL DEFAULT 0,
    "partialCount" INTEGER NOT NULL DEFAULT 0,
    "unpaidCount" INTEGER NOT NULL DEFAULT 0,
    "status" "PaymentStatus" NOT NULL DEFAULT 'UNPAID',
    "note" TEXT,
    "createdById" UUID,
    "createdByName" TEXT,
    "updatedById" UUID,
    "updatedByName" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ImamSalaryMonth_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ImamSalaryAssignment" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "imamSalaryMonthId" UUID NOT NULL,
    "memberId" UUID NOT NULL,
    "memberName" TEXT NOT NULL,
    "memberPhone" TEXT NOT NULL,
    "expectedAmount" DECIMAL(12,2) NOT NULL,
    "paidAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "dueAmount" DECIMAL(12,2) NOT NULL,
    "status" "ImamSalaryAssignmentStatus" NOT NULL DEFAULT 'UNPAID',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ImamSalaryAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ImamSalaryPayment" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "imamSalaryMonthId" UUID NOT NULL,
    "assignmentId" UUID NOT NULL,
    "memberId" UUID NOT NULL,
    "memberName" TEXT NOT NULL,
    "memberPhone" TEXT NOT NULL,
    "amount" DECIMAL(12,2) NOT NULL,
    "paymentMode" "PaymentMode" NOT NULL,
    "paymentForMonth" INTEGER NOT NULL,
    "paymentForYear" INTEGER NOT NULL,
    "paidAt" TIMESTAMP(3) NOT NULL,
    "collectedById" UUID NOT NULL,
    "collectedByName" TEXT NOT NULL,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ImamSalaryPayment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Project" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "targetAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "collectedAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "spentAmount" DECIMAL(12,2) NOT NULL DEFAULT 0,
    "status" "ProjectStatus" NOT NULL DEFAULT 'ONGOING',
    "startDate" TIMESTAMP(3),
    "endDate" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Project_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Announcement" (
    "id" UUID NOT NULL,
    "masjidId" UUID NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Announcement_pkey" PRIMARY KEY ("id")
);

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
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_phone_key" ON "User"("phone");

-- CreateIndex
CREATE INDEX "User_masjidId_idx" ON "User"("masjidId");

-- CreateIndex
CREATE UNIQUE INDEX "Role_name_key" ON "Role"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Permission_name_key" ON "Permission"("name");

-- CreateIndex
CREATE INDEX "RolePermission_roleId_idx" ON "RolePermission"("roleId");

-- CreateIndex
CREATE INDEX "RolePermission_permissionId_idx" ON "RolePermission"("permissionId");

-- CreateIndex
CREATE UNIQUE INDEX "RolePermission_roleId_permissionId_key" ON "RolePermission"("roleId", "permissionId");

-- CreateIndex
CREATE INDEX "UserRole_userId_idx" ON "UserRole"("userId");

-- CreateIndex
CREATE INDEX "UserRole_roleId_idx" ON "UserRole"("roleId");

-- CreateIndex
CREATE UNIQUE INDEX "UserRole_userId_roleId_key" ON "UserRole"("userId", "roleId");

-- CreateIndex
CREATE INDEX "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE INDEX "Session_expiresAt_idx" ON "Session"("expiresAt");

-- CreateIndex
CREATE INDEX "Masjid_createdById_idx" ON "Masjid"("createdById");

-- CreateIndex
CREATE INDEX "Masjid_imamUserId_idx" ON "Masjid"("imamUserId");

-- CreateIndex
CREATE INDEX "Masjid_status_idx" ON "Masjid"("status");

-- CreateIndex
CREATE INDEX "Masjid_approvedById_idx" ON "Masjid"("approvedById");

-- CreateIndex
CREATE INDEX "MasjidRegistrationRequest_requestedById_idx" ON "MasjidRegistrationRequest"("requestedById");

-- CreateIndex
CREATE INDEX "MasjidRegistrationRequest_reviewedById_idx" ON "MasjidRegistrationRequest"("reviewedById");

-- CreateIndex
CREATE INDEX "MasjidRegistrationRequest_status_idx" ON "MasjidRegistrationRequest"("status");

-- CreateIndex
CREATE INDEX "MasjidRegistrationRequest_createdMasjidId_idx" ON "MasjidRegistrationRequest"("createdMasjidId");

-- CreateIndex
CREATE UNIQUE INDEX "NamazTime_masjidId_key" ON "NamazTime"("masjidId");

-- CreateIndex
CREATE INDEX "ImamSalary_masjidId_idx" ON "ImamSalary"("masjidId");

-- CreateIndex
CREATE INDEX "ImamSalary_imamId_idx" ON "ImamSalary"("imamId");

-- CreateIndex
CREATE INDEX "ImamSalary_status_idx" ON "ImamSalary"("status");

-- CreateIndex
CREATE UNIQUE INDEX "ImamSalary_masjidId_month_year_key" ON "ImamSalary"("masjidId", "month", "year");

-- CreateIndex
CREATE INDEX "ImamSalaryMonth_masjidId_year_month_idx" ON "ImamSalaryMonth"("masjidId", "year", "month");

-- CreateIndex
CREATE UNIQUE INDEX "ImamSalaryMonth_masjidId_month_year_key" ON "ImamSalaryMonth"("masjidId", "month", "year");

-- CreateIndex
CREATE INDEX "ImamSalaryAssignment_masjidId_status_idx" ON "ImamSalaryAssignment"("masjidId", "status");

-- CreateIndex
CREATE INDEX "ImamSalaryAssignment_memberId_idx" ON "ImamSalaryAssignment"("memberId");

-- CreateIndex
CREATE UNIQUE INDEX "ImamSalaryAssignment_imamSalaryMonthId_memberId_key" ON "ImamSalaryAssignment"("imamSalaryMonthId", "memberId");

-- CreateIndex
CREATE INDEX "ImamSalaryPayment_masjidId_paymentForYear_paymentForMonth_idx" ON "ImamSalaryPayment"("masjidId", "paymentForYear", "paymentForMonth");

-- CreateIndex
CREATE INDEX "ImamSalaryPayment_memberId_idx" ON "ImamSalaryPayment"("memberId");

-- CreateIndex
CREATE INDEX "ImamSalaryPayment_paidAt_idx" ON "ImamSalaryPayment"("paidAt");

-- CreateIndex
CREATE INDEX "ImamSalaryPayment_paymentMode_idx" ON "ImamSalaryPayment"("paymentMode");

-- CreateIndex
CREATE INDEX "ImamSalaryPayment_collectedById_idx" ON "ImamSalaryPayment"("collectedById");

-- CreateIndex
CREATE INDEX "Project_masjidId_idx" ON "Project"("masjidId");

-- CreateIndex
CREATE INDEX "Project_status_idx" ON "Project"("status");

-- CreateIndex
CREATE INDEX "Announcement_masjidId_idx" ON "Announcement"("masjidId");

-- CreateIndex
CREATE INDEX "Announcement_isActive_idx" ON "Announcement"("isActive");

-- CreateIndex
CREATE INDEX "Collection_masjidId_idx" ON "Collection"("masjidId");

-- CreateIndex
CREATE INDEX "Collection_type_idx" ON "Collection"("type");

-- CreateIndex
CREATE INDEX "Collection_status_idx" ON "Collection"("status");

-- CreateIndex
CREATE INDEX "Collection_collectedAt_idx" ON "Collection"("collectedAt");

-- CreateIndex
CREATE INDEX "Collection_createdById_idx" ON "Collection"("createdById");

-- CreateIndex
CREATE INDEX "Expense_masjidId_idx" ON "Expense"("masjidId");

-- CreateIndex
CREATE INDEX "Expense_type_idx" ON "Expense"("type");

-- CreateIndex
CREATE INDEX "Expense_status_idx" ON "Expense"("status");

-- CreateIndex
CREATE INDEX "Expense_spentAt_idx" ON "Expense"("spentAt");

-- CreateIndex
CREATE INDEX "Expense_createdById_idx" ON "Expense"("createdById");

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RolePermission" ADD CONSTRAINT "RolePermission_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "Role"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RolePermission" ADD CONSTRAINT "RolePermission_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES "Permission"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserRole" ADD CONSTRAINT "UserRole_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "UserRole" ADD CONSTRAINT "UserRole_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "Role"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Masjid" ADD CONSTRAINT "Masjid_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Masjid" ADD CONSTRAINT "Masjid_imamUserId_fkey" FOREIGN KEY ("imamUserId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Masjid" ADD CONSTRAINT "Masjid_approvedById_fkey" FOREIGN KEY ("approvedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MasjidRegistrationRequest" ADD CONSTRAINT "MasjidRegistrationRequest_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MasjidRegistrationRequest" ADD CONSTRAINT "MasjidRegistrationRequest_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MasjidRegistrationRequest" ADD CONSTRAINT "MasjidRegistrationRequest_createdMasjidId_fkey" FOREIGN KEY ("createdMasjidId") REFERENCES "Masjid"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "NamazTime" ADD CONSTRAINT "NamazTime_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalary" ADD CONSTRAINT "ImamSalary_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalary" ADD CONSTRAINT "ImamSalary_imamId_fkey" FOREIGN KEY ("imamId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryMonth" ADD CONSTRAINT "ImamSalaryMonth_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryAssignment" ADD CONSTRAINT "ImamSalaryAssignment_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryAssignment" ADD CONSTRAINT "ImamSalaryAssignment_imamSalaryMonthId_fkey" FOREIGN KEY ("imamSalaryMonthId") REFERENCES "ImamSalaryMonth"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryAssignment" ADD CONSTRAINT "ImamSalaryAssignment_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_imamSalaryMonthId_fkey" FOREIGN KEY ("imamSalaryMonthId") REFERENCES "ImamSalaryMonth"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "ImamSalaryAssignment"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_memberId_fkey" FOREIGN KEY ("memberId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ImamSalaryPayment" ADD CONSTRAINT "ImamSalaryPayment_collectedById_fkey" FOREIGN KEY ("collectedById") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Project" ADD CONSTRAINT "Project_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Announcement" ADD CONSTRAINT "Announcement_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Collection" ADD CONSTRAINT "Collection_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Collection" ADD CONSTRAINT "Collection_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_masjidId_fkey" FOREIGN KEY ("masjidId") REFERENCES "Masjid"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
