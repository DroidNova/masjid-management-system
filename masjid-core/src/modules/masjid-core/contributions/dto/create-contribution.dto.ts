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
  @IsOptional()
  @IsUUID('4')
  memberId?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(150)
  contributorName!: string;

  @IsOptional()
  @IsString()
  @MaxLength(30)
  contributorPhone?: string;

  @Type(() => Number)
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(0.01)
  amount!: number;

  @IsEnum(ContributionPaymentModeDto)
  paymentMode!: ContributionPaymentModeDto;

  @IsDateString()
  paidAt!: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}

export class CreateCollectionContributionDto extends CreateContributionDto {
  @IsEnum(CollectionTypeDto)
  collectionType!: CollectionTypeDto;
}
