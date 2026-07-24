CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');

ALTER TABLE "User"
ADD COLUMN "fatherName" TEXT,
ADD COLUMN "age" INTEGER,
ADD COLUMN "gender" "Gender",
ADD COLUMN "isFamilyHead" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN "familyMemberCount" INTEGER;

ALTER TABLE "MasjidRegistrationRequest"
ADD COLUMN "imamFatherName" TEXT,
ADD COLUMN "imamAge" INTEGER,
ADD COLUMN "imamGender" "Gender";
