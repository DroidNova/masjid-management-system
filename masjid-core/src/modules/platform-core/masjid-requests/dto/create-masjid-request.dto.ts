import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsEmail,
  IsOptional,
  ValidateIf,
  IsString,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class ImamDetailsDto {
  @ApiProperty({ example: 'Imam Name', maxLength: 150 })
  @Transform(trimString)
  @IsString({ message: 'Imam name must be a string' })
  @MinLength(1, { message: 'Imam name is required' })
  @MaxLength(150, { message: 'Imam name must be 150 characters or less' })
  name!: string;

  @ApiPropertyOptional({ example: 'imam@example.com', maxLength: 255 })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsOptional()
  @IsEmail({}, { message: 'Imam email must be a valid email address' })
  @MaxLength(255, { message: 'Imam email must be 255 characters or less' })
  email?: string;

  @ApiProperty({ example: '9876543210', maxLength: 20 })
  @Transform(trimString)
  @IsString({ message: 'Imam phone must be a string' })
  @MinLength(1, { message: 'Imam phone is required' })
  @MaxLength(20, { message: 'Imam phone must be 20 characters or less' })
  phone!: string;

  @ApiPropertyOptional({ example: 'Single line address', maxLength: 500 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Imam address must be a string' })
  @MaxLength(500, { message: 'Imam address must be 500 characters or less' })
  address?: string;
}

export class CommitteeMemberDto {
  @ApiProperty({ example: 'Committee Member Name', maxLength: 150 })
  @Transform(trimString)
  @IsString({ message: 'Committee member name must be a string' })
  @MinLength(1, { message: 'Committee member name is required' })
  @MaxLength(150, {
    message: 'Committee member name must be 150 characters or less',
  })
  name!: string;

  @ApiProperty({ example: '9876543211', maxLength: 20 })
  @Transform(trimString)
  @IsString({ message: 'Committee member phone must be a string' })
  @MinLength(1, { message: 'Committee member phone is required' })
  @MaxLength(20, {
    message: 'Committee member phone must be 20 characters or less',
  })
  phone!: string;
}

export class CreateMasjidRequestDto {
  @ApiProperty({ example: 'Person Name', minLength: 2, maxLength: 150 })
  @Transform(trimString)
  @IsString({ message: 'Requester name must be a string' })
  @MinLength(2, { message: 'Requester name must be at least 2 characters' })
  @MaxLength(150, { message: 'Requester name must be 150 characters or less' })
  requesterName!: string;

  @ApiProperty({ example: '9876543210', maxLength: 20 })
  @Transform(trimString)
  @IsString({ message: 'Requester phone must be a string' })
  @MinLength(5, { message: 'Requester phone must be at least 5 characters' })
  @MaxLength(20, { message: 'Requester phone must be 20 characters or less' })
  requesterPhone!: string;

  @ApiPropertyOptional({ example: 'person@example.com', maxLength: 255 })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsOptional()
  @IsEmail({}, { message: 'Requester email must be a valid email address' })
  @MaxLength(255, { message: 'Requester email must be 255 characters or less' })
  requesterEmail?: string;

  @ApiProperty({ example: 'Jama Masjid', minLength: 2, maxLength: 150 })
  @Transform(trimString)
  @IsString({ message: 'Masjid name must be a string' })
  @MinLength(2, { message: 'Masjid name must be at least 2 characters' })
  @MaxLength(150, { message: 'Masjid name must be 150 characters or less' })
  masjidName!: string;

  @ApiProperty({ example: 'India', maxLength: 100 })
  @Transform(trimString)
  @IsString({ message: 'Country must be a string' })
  @MinLength(1, { message: 'Country is required' })
  @MaxLength(100, { message: 'Country must be 100 characters or less' })
  country!: string;

  @ApiPropertyOptional({ example: 'District', maxLength: 100, description: 'Required when country is India or IN' })
  @Transform(trimString)
  @ValidateIf((dto: CreateMasjidRequestDto) => ['india', 'in'].includes(String(dto.country ?? '').trim().toLowerCase()))
  @IsString({ message: 'District must be a string' })
  @MinLength(1, { message: 'District is required for India' })
  @MaxLength(100, { message: 'District must be 100 characters or less' })
  district?: string;

  @ApiProperty({ example: 'Nighasan', maxLength: 100, description: 'City / Village / Town' })
  @Transform(trimString)
  @IsString({ message: 'Locality must be a string' })
  @MinLength(1, { message: 'City / Village / Town is required' })
  @MaxLength(100, { message: 'Locality must be 100 characters or less' })
  locality!: string;

  @ApiProperty({ example: 'State', maxLength: 100 })
  @Transform(trimString)
  @IsString({ message: 'State must be a string' })
  @MinLength(1, { message: 'State is required' })
  @MaxLength(100, { message: 'State must be 100 characters or less' })
  state!: string;

  @ApiProperty({ example: 'Address', maxLength: 500 })
  @Transform(trimString)
  @IsString({ message: 'Address must be a string' })
  @MinLength(1, { message: 'Address is required' })
  @MaxLength(500, { message: 'Address must be 500 characters or less' })
  address!: string;

  @ApiPropertyOptional({ example: '9876543210', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Contact number must be a string' })
  @MaxLength(20, { message: 'Contact number must be 20 characters or less' })
  contactNo?: string;

  @ApiPropertyOptional({ example: 'Short description', maxLength: 1000 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Description must be a string' })
  @MaxLength(1000, { message: 'Description must be 1000 characters or less' })
  description?: string;

  @ApiPropertyOptional({ example: 'Assalamu Alaikum', maxLength: 500 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Welcome message must be a string' })
  @MaxLength(500, { message: 'Welcome message must be 500 characters or less' })
  welcomeMsg?: string;

  @ApiProperty({ example: 'Imam Name', maxLength: 150 })
  @Transform(trimString)
  @IsString({ message: 'Imam name must be a string' })
  @MinLength(1, { message: 'Imam name is required' })
  @MaxLength(150, { message: 'Imam name must be 150 characters or less' })
  imamName!: string;

  @ApiProperty({ example: '9876543210', maxLength: 20 })
  @Transform(trimString)
  @IsString({ message: 'Imam phone must be a string' })
  @MinLength(1, { message: 'Imam phone is required' })
  @MaxLength(20, { message: 'Imam phone must be 20 characters or less' })
  imamPhone!: string;

  @ApiPropertyOptional({ example: 'imam@example.com', maxLength: 255 })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsOptional()
  @IsEmail({}, { message: 'Imam email must be a valid email address' })
  @MaxLength(255, { message: 'Imam email must be 255 characters or less' })
  imamEmail?: string;

  @ApiProperty({ example: 'Single line imam address', maxLength: 500 })
  @Transform(trimString)
  @IsString({ message: 'Imam address must be a string' })
  @MinLength(1, { message: 'Imam address is required' })
  @MaxLength(500, { message: 'Imam address must be 500 characters or less' })
  imamAddress!: string;

  @ApiPropertyOptional({ type: ImamDetailsDto, deprecated: true })
  @IsOptional()
  @ValidateNested()
  @Type(() => ImamDetailsDto)
  imam?: ImamDetailsDto;

  @ApiProperty({ type: [CommitteeMemberDto] })
  @IsArray({ message: 'Committee members must be an array' })
  @ArrayMinSize(1, { message: 'At least one committee member is required' })
  @ValidateNested({ each: true })
  @Type(() => CommitteeMemberDto)
  committeeMembers!: CommitteeMemberDto[];
}
