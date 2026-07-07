import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export enum MasjidRequestStatusActionDto {
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

export class UpdateMasjidRequestStatusDto {
  @ApiProperty({
    enum: MasjidRequestStatusActionDto,
    example: MasjidRequestStatusActionDto.APPROVED,
  })
  @IsEnum(MasjidRequestStatusActionDto)
  status!: MasjidRequestStatusActionDto;

  @ApiPropertyOptional({ example: 'Verified successfully', maxLength: 500 })
  @Transform(trimString)
  @IsOptional()
  @IsString({ message: 'Reason must be a string' })
  @MaxLength(500, { message: 'Reason must be 500 characters or less' })
  reason?: string;
}
