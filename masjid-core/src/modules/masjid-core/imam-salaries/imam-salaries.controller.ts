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
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
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

type AuthenticatedRequest = { user: AuthenticatedUser };
const managers = ['SUPER_ADMIN', 'MASJID_ADMIN', 'COMMITTEE_MEMBER'] as const;

@ApiTags('Imam Salary Ledger')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('imam-salaries')
export class ImamSalariesController {
  constructor(private readonly service: ImamSalariesService) {}

  @Get('my-history')
  @Roles('MEMBER')
  myHistory(
    @Query() query: MySalaryHistoryQueryDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.myHistory(query, req.user);
  }

  @Post('months')
  @Roles(...managers)
  createMonth(
    @Body() dto: CreateSalaryMonthDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.createMonth(dto, req.user);
  }

  @Get('months')
  @Roles(...managers, 'IMAM')
  listMonths(
    @Query() query: SalaryMonthsQueryDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.listMonths(query, req.user);
  }

  @Get('months/:id/assignments')
  @Roles(...managers)
  assignments(
    @Param('id', ParseUUIDPipe) id: string,
    @Query() query: SalaryAssignmentsQueryDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.listAssignments(id, query, req.user);
  }

  @Patch('months/:id/amount')
  @Roles(...managers)
  updateAmount(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSalaryAmountDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.updateAmount(id, dto, req.user);
  }

  @Get('months/:id')
  @Roles(...managers, 'IMAM')
  month(
    @Param('id', ParseUUIDPipe) id: string,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.getMonth(id, req.user);
  }

  @Post('payments')
  @Roles(...managers)
  addPayment(
    @Body() dto: CreateSalaryPaymentDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.addPayment(dto, req.user);
  }

  @Get('payments')
  @Roles(...managers)
  payments(
    @Query() query: SalaryPaymentsQueryDto,
    @Req() req: AuthenticatedRequest,
  ) {
    return this.service.listPayments(query, req.user);
  }
}
