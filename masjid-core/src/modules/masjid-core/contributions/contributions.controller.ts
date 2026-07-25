import {
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { ContributionsService } from './contributions.service';
import { MyContributionQueryDto } from './dto/my-contribution-query.dto';
import { MyPaymentsQueryDto } from './dto/my-payments-query.dto';

type AuthenticatedRequest = { user: AuthenticatedUser };

@ApiTags('My Contributions')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('contributions/my')
export class ContributionsController {
  constructor(private readonly contributionsService: ContributionsService) {}

  @Get('summary')
  getSummary(@Req() request: AuthenticatedRequest) {
    return this.contributionsService.getSummary(request.user);
  }

  @Get('imam-salary')
  getImamSalaryHistory(
    @Query() query: MyContributionQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.contributionsService.getImamSalaryHistory(query, request.user);
  }

  @Get('imam-salary/:month/:year/payments')
  getImamSalaryPayments(
    @Param('month', ParseIntPipe) month: number,
    @Param('year', ParseIntPipe) year: number,
    @Query() query: MyPaymentsQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.contributionsService.getImamSalaryPayments(
      month,
      year,
      query,
      request.user,
    );
  }
}
