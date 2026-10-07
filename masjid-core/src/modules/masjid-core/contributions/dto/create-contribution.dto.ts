import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { CollectionTypeDto } from '../../collections/dto/create-collection.dto';

export enum ContributionPaymentModeDto {
  CASH = 'CASH',
  ONLINE = 'ONLINE',
}

export class CreateContributionDto {
  @ApiPropertyOptional({
    description: 'Member who paid, if they belong to this masjid',
    format: 'uuid',
  })
  @IsOptional()
  @IsUUID('4')
  memberId?: string;

  @ApiProperty({ example: 'Rafiq Ahmed', maxLength: 150 })
  @IsString()
  @MinLength(1)
  @MaxLength(150)
  contributorName!: string;

  @ApiPropertyOptional({ example: '+919876543210', maxLength: 30 })
  @IsOptional()
  @IsString()
  @MaxLength(30)
  contributorPhone?: string;

  @ApiProperty({
    example: 1000.5,
    minimum: 0.01,
    description: 'Rupees, up to 2 decimals',
  })
  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;

  @ApiProperty({
    enum: ContributionPaymentModeDto,
    example: ContributionPaymentModeDto.CASH,
  })
  @IsEnum(ContributionPaymentModeDto)
  paymentMode!: ContributionPaymentModeDto;

  @ApiProperty({ example: '2026-09-10T10:00:00.000Z', format: 'date-time' })
  @IsDateString()
  paidAt!: string;

  @ApiPropertyOptional({ example: 'Paid at Jumma', maxLength: 500 })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}

export class CreateCollectionContributionDto extends CreateContributionDto {
  @ApiProperty({ enum: CollectionTypeDto, example: CollectionTypeDto.ZAKAT })
  @IsEnum(CollectionTypeDto)
  collectionType!: CollectionTypeDto;
}
