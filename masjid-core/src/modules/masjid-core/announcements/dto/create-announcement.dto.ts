import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';

const trimString = ({ value }: { value: unknown }) =>
  typeof value === 'string' ? value.trim() : value;

export class CreateAnnouncementDto {
  @ApiProperty({ example: 'Jumma Timing Update', maxLength: 150 })
  @Transform(trimString)
  @IsString({ message: 'Title must be a string' })
  @MinLength(1, { message: 'Title is required' })
  @MaxLength(150, { message: 'Title must be 150 characters or less' })
  title!: string;

  @ApiProperty({ example: 'Jumma namaz will be at 1:15 PM.', maxLength: 2000 })
  @Transform(trimString)
  @IsString({ message: 'Message must be a string' })
  @MinLength(1, { message: 'Message is required' })
  @MaxLength(2000, { message: 'Message must be 2000 characters or less' })
  message!: string;

  @ApiPropertyOptional({ example: true, default: true })
  @IsOptional()
  @IsBoolean({ message: 'isActive must be a boolean' })
  isActive?: boolean;
}
