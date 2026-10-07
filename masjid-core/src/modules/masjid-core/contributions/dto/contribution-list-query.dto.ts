import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { PaginationQueryDto } from '../../../../common/dto/pagination-query.dto';
import { CollectionTypeDto } from '../../collections/dto/create-collection.dto';
import { ContributionPaymentModeDto } from './create-contribution.dto';

export class ContributionListQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({
    description: 'Contributor name or phone',
    maxLength: 100,
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  search?: string;

  @ApiPropertyOptional({ enum: ContributionPaymentModeDto })
  @IsOptional()
  @IsEnum(ContributionPaymentModeDto)
  paymentMode?: ContributionPaymentModeDto;

  @ApiPropertyOptional({ format: 'date-time' })
  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @ApiPropertyOptional({ format: 'date-time' })
  @IsOptional()
  @IsDateString()
  toDate?: string;
}

export class CollectionContributionListQueryDto extends ContributionListQueryDto {
  @ApiPropertyOptional({ enum: CollectionTypeDto })
  @IsOptional()
  @IsEnum(CollectionTypeDto)
  collectionType?: CollectionTypeDto;
}

export class MyContributionListQueryDto extends PaginationQueryDto {
  @ApiPropertyOptional({ format: 'date-time' })
  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @ApiPropertyOptional({ format: 'date-time' })
  @IsOptional()
  @IsDateString()
  toDate?: string;
}
