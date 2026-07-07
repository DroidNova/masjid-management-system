import {
  Controller,
  Get,
  HttpStatus,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsDateString, IsInt, IsOptional, Max, Min } from 'class-validator';
import { JwtAuthGuard } from '../../platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { FinanceService } from './finance.service';

type AuthenticatedRequest = { user: AuthenticatedUser };
const toOptionalNumber = ({ value }: { value: unknown }) =>
  value === undefined || value === null || value === ''
    ? undefined
    : Number(value);
const toOptionalDate = ({ value }: { value: unknown }) =>
  value === undefined || value === null || value === '' ? undefined : value;

class FinanceSummaryQueryDto {
  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'From date must be a valid ISO date string' })
  fromDate?: string;

  @Transform(toOptionalDate)
  @IsOptional()
  @IsDateString({}, { message: 'To date must be a valid ISO date string' })
  toDate?: string;

  @Transform(toOptionalNumber)
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(12)
  month?: number;

  @Transform(toOptionalNumber)
  @IsOptional()
  @IsInt()
  @Min(1900)
  year?: number;
}

@ApiTags('Finance')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('finance')
export class FinanceController {
  constructor(private readonly financeService: FinanceService) {}

  @Get('my-masjid/summary')
  @ApiOperation({ summary: "Get current masjid's finance summary" })
  @ApiQuery({ name: 'fromDate', required: false, type: String })
  @ApiQuery({ name: 'toDate', required: false, type: String })
  @ApiQuery({ name: 'month', required: false, type: Number, example: 6 })
  @ApiQuery({ name: 'year', required: false, type: Number, example: 2026 })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Finance summary retrieved successfully',
  })
  getMyMasjidSummary(
    @Query() query: FinanceSummaryQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.financeService.getMyMasjidSummary(query, request.user);
  }
}
