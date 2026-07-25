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
  @IsOptional()
  @IsString()
  @MaxLength(100)
  search?: string;

  @IsOptional()
  @IsEnum(ContributionPaymentModeDto)
  paymentMode?: ContributionPaymentModeDto;

  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @IsOptional()
  @IsDateString()
  toDate?: string;
}

export class CollectionContributionListQueryDto extends ContributionListQueryDto {
  @IsOptional()
  @IsEnum(CollectionTypeDto)
  collectionType?: CollectionTypeDto;
}

export class MyContributionListQueryDto extends PaginationQueryDto {
  @IsOptional()
  @IsDateString()
  fromDate?: string;

  @IsOptional()
  @IsDateString()
  toDate?: string;
}
