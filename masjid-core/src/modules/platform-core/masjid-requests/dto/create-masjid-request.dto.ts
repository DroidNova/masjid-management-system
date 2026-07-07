import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsArray,
  IsEmail,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class ImamDetailsDto {
  @ApiPropertyOptional({ example: 'Imam Name', maxLength: 150 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Imam name must be a string' })
  @MaxLength(150, { message: 'Imam name must be 150 characters or less' })
  name?: string;

  @ApiPropertyOptional({ example: 'imam@example.com', maxLength: 255 })
  @Transform(({ value }: { value: unknown }) =>
    typeof value === 'string' ? value.trim().toLowerCase() : value,
  )
  @IsOptional()
  @IsEmail({}, { message: 'Imam email must be a valid email address' })
  @MaxLength(255, { message: 'Imam email must be 255 characters or less' })
  email?: string;

  @ApiPropertyOptional({ example: '9876543210', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Imam phone must be a string' })
  @MaxLength(20, { message: 'Imam phone must be 20 characters or less' })
  phone?: string;

  @ApiPropertyOptional({ example: 'Single line address', maxLength: 500 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Imam address must be a string' })
  @MaxLength(500, { message: 'Imam address must be 500 characters or less' })
  address?: string;
}

export class CommitteeMemberDto {
  @ApiPropertyOptional({ example: 'Committee Member Name', maxLength: 150 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Committee member name must be a string' })
  @MaxLength(150, {
    message: 'Committee member name must be 150 characters or less',
  })
  name?: string;

  @ApiPropertyOptional({ example: '9876543211', maxLength: 20 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Committee member phone must be a string' })
  @MaxLength(20, {
    message: 'Committee member phone must be 20 characters or less',
  })
  phone?: string;
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

  @ApiPropertyOptional({ example: 'Village Name', maxLength: 100 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Village must be a string' })
  @MaxLength(100, { message: 'Village must be 100 characters or less' })
  village?: string;

  @ApiPropertyOptional({ example: 'City', maxLength: 100 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'City must be a string' })
  @MaxLength(100, { message: 'City must be 100 characters or less' })
  city?: string;

  @ApiPropertyOptional({ example: 'District', maxLength: 100 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'District must be a string' })
  @MaxLength(100, { message: 'District must be 100 characters or less' })
  district?: string;

  @ApiPropertyOptional({ example: 'State', maxLength: 100 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'State must be a string' })
  @MaxLength(100, { message: 'State must be 100 characters or less' })
  state?: string;

  @ApiPropertyOptional({ example: 'Address', maxLength: 500 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Address must be a string' })
  @MaxLength(500, { message: 'Address must be 500 characters or less' })
  address?: string;

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

  @ApiPropertyOptional({ type: ImamDetailsDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => ImamDetailsDto)
  imam?: ImamDetailsDto;

  @ApiPropertyOptional({ type: [CommitteeMemberDto] })
  @IsOptional()
  @IsArray({ message: 'Committee members must be an array' })
  @ValidateNested({ each: true })
  @Type(() => CommitteeMemberDto)
  committeeMembers?: CommitteeMemberDto[];
}
