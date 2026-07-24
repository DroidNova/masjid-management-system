import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsEmail,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

export enum CreateMasjidUserRoleDto {
  MEMBER = 'MEMBER',
  IMAM = 'IMAM',
  COMMITTEE_MEMBER = 'COMMITTEE_MEMBER',
}

export enum GenderDto {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
  OTHER = 'OTHER',
}

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class CreateMasjidUserDto {
  @ApiProperty({ example: 'Ali Khan', minLength: 2, maxLength: 50 })
  @Transform(trimString)
  @IsString({ message: 'Full name must be a string' })
  @MinLength(2, { message: 'Full name must be at least 2 characters' })
  @MaxLength(50, { message: 'Full name must be 50 characters or less' })
  fullName!: string;

  @ApiProperty({ example: '9876543210', minLength: 6, maxLength: 20 })
  @Transform(trimString)
  @IsString({ message: 'Phone must be a string' })
  @MinLength(6, { message: 'Phone must be at least 6 characters' })
  @MaxLength(20, { message: 'Phone must be 20 characters or less' })
  phone!: string;

  @ApiPropertyOptional({ example: 'user@example.com', maxLength: 254 })
  @Transform(({ value }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsOptional()
  @IsEmail({}, { message: 'Email must be a valid email address' })
  @MaxLength(254, { message: 'Email must be 254 characters or less' })
  email?: string;

  @ApiProperty({ example: 'Rahim Khan', maxLength: 150 })
  @Transform(trimString)
  @IsString({ message: 'Father name must be a string' })
  @MinLength(1, { message: 'Father name is required' })
  @MaxLength(150, { message: 'Father name must be 150 characters or less' })
  fatherName!: string;

  @ApiProperty({ example: 45, minimum: 1, maximum: 120 })
  @IsInt({ message: 'Age must be a whole number' })
  @Min(1, { message: 'Age must be at least 1' })
  @Max(120, { message: 'Age must be 120 or less' })
  age!: number;

  @ApiProperty({ enum: GenderDto, example: GenderDto.MALE })
  @IsEnum(GenderDto, { message: 'Gender must be MALE, FEMALE, or OTHER' })
  gender!: GenderDto;

  @ApiProperty({
    enum: CreateMasjidUserRoleDto,
    example: CreateMasjidUserRoleDto.MEMBER,
  })
  @IsEnum(CreateMasjidUserRoleDto)
  role!: CreateMasjidUserRoleDto;

  @ApiPropertyOptional({
    example: false,
    description: 'Required when role is MEMBER',
  })
  @IsOptional()
  @IsBoolean({ message: 'Is family head must be true or false' })
  isFamilyHead?: boolean;

  @ApiPropertyOptional({ example: 5, minimum: 0 })
  @IsOptional()
  @IsInt({ message: 'Family member count must be a whole number' })
  @Min(0, { message: 'Family member count cannot be negative' })
  familyMemberCount?: number;

  @ApiPropertyOptional({
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
    description:
      'Only SUPER_ADMIN may provide this when not assigned to a masjid',
  })
  @Transform(trimString)
  @IsOptional()
  @IsUUID('4')
  masjidId?: string;
}
