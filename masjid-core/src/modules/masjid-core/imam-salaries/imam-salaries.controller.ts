import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateSalaryMonthDto,
  CreateSalaryPaymentDto,
  MySalaryHistoryQueryDto,
  SalaryAssignmentsQueryDto,
  SalaryMonthsQueryDto,
  SalaryPaymentsQueryDto,
  UpdateSalaryAmountDto,
} from './dto/imam-salary-ledger.dto';
import { ImamSalariesService } from './imam-salaries.service';
import { PERMISSIONS } from '../../../access/permissions';
import { RequirePermissions } from '../../../access/require-permissions';

type AuthenticatedRequest = { user: AuthenticatedUser };

@ApiTags('Imam Salary Ledger')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('imam-salaries')
export class ImamSalariesController {
  constructor(private readonly service: ImamSalariesService) {}

  @Get('my-history')
  @RequirePermissions(PERMISSIONS.OWN_CONTRIBUTIONS_READ)
  myHistory(
    @Query() query: MySalaryHistoryQueryDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.myHistory(query, req.user);
  }

  @Post('months')
  @RequirePermissions(PERMISSIONS.IMAM_SALARY_MANAGE)
  createMonth(
    @Body() dto: CreateSalaryMonthDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.createMonth(dto, req.user);
  }

  @Get('months')
  @RequirePermissions(PERMISSIONS.IMAM_SALARY_READ)
  listMonths(
    @Query() query: SalaryMonthsQueryDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.listMonths(query, req.user);
  }

  @Get('months/:id/assignments')
  @RequirePermissions(PERMISSIONS.IMAM_SALARY_MANAGE)
  assignments(
    @Param('id', ParseUUIDPipe) id: string,
    @Query() query: SalaryAssignmentsQueryDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.listAssignments(id, query, req.user);
  }

  @Patch('months/:id/amount')
  @RequirePermissions(PERMISSIONS.IMAM_SALARY_MANAGE)
  updateAmount(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSalaryAmountDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.updateAmount(id, dto, req.user);
  }

  @Get('months/:id')
  @RequirePermissions(PERMISSIONS.IMAM_SALARY_READ)
  month(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.getMonth(id, req.user);
  }

  @Post('payments')
  @RequirePermissions(PERMISSIONS.IMAM_SALARY_MANAGE)
  addPayment(
    @Body() dto: CreateSalaryPaymentDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.addPayment(dto, req.user);
  }

  @Get('payments')
  @RequirePermissions(PERMISSIONS.IMAM_SALARY_MANAGE)
  payments(
    @Query() query: SalaryPaymentsQueryDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.listPayments(query, req.user);
  }
}
