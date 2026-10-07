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
import { MyContributionListQueryDto } from './dto/contribution-list-query.dto';
import { MyContributionQueryDto } from './dto/my-contribution-query.dto';
import { MyPaymentsQueryDto } from './dto/my-payments-query.dto';
import { PERMISSIONS } from '../../../access/permissions';
import { RequirePermissions } from '../../../access/require-permissions';

type AuthenticatedRequest = { user: AuthenticatedUser };

@ApiTags('My Contributions')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('contributions/my')
export class ContributionsController {
  constructor(private readonly contributionsService: ContributionsService) {}

  @Get('summary')
  @RequirePermissions(PERMISSIONS.OWN_CONTRIBUTIONS_READ)
  getSummary(@Req() request: AuthenticatedRequest) {
    return this.contributionsService.getSummary(request.user);
  }

  @Get('projects')
  @RequirePermissions(PERMISSIONS.OWN_CONTRIBUTIONS_READ)
  getProjectContributions(
    @Query() query: MyContributionListQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.contributionsService.getMyProjectContributions(
      query,
      request.user,
    );
  }

  @Get('collections')
  @RequirePermissions(PERMISSIONS.OWN_CONTRIBUTIONS_READ)
  getCollectionContributions(
    @Query() query: MyContributionListQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.contributionsService.getMyCollectionContributions(
      query,
      request.user,
    );
  }

  @Get('imam-salary')
  @RequirePermissions(PERMISSIONS.OWN_CONTRIBUTIONS_READ)
  getImamSalaryHistory(
    @Query() query: MyContributionQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.contributionsService.getImamSalaryHistory(query, request.user);
  }

  @Get('imam-salary/:month/:year/payments')
  @RequirePermissions(PERMISSIONS.OWN_CONTRIBUTIONS_READ)
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
