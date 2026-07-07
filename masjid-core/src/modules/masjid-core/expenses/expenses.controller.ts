import {
  Body,
  Controller,
  Delete,
  Get,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Roles } from '../../../common/decorators/roles.decorator';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { JwtAuthGuard } from '../../platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import {
  CreateExpenseDto,
  ExpenseTypeDto,
  FinanceEntryStatusDto,
} from './dto/create-expense.dto';
import { GetExpensesQueryDto } from './dto/get-expenses-query.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';
import { ExpensesService } from './expenses.service';

type AuthenticatedRequest = { user: AuthenticatedUser };
const standardErrorSchema = {
  example: {
    success: false,
    message: 'Current user is not assigned to a masjid',
    errorCode: 'USER_MASJID_NOT_ASSIGNED',
  },
};

@ApiTags('Expenses')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('expenses')
export class ExpensesController {
  constructor(private readonly expensesService: ExpensesService) {}

  @Get('my-masjid')
  @ApiOperation({ summary: "Get current masjid's expenses" })
  @ApiQuery({ name: 'type', required: false, enum: ExpenseTypeDto })
  @ApiQuery({ name: 'status', required: false, enum: FinanceEntryStatusDto })
  @ApiQuery({ name: 'fromDate', required: false, type: String })
  @ApiQuery({ name: 'toDate', required: false, type: String })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Expenses retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  findMyMasjidExpenses(
    @Query() query: GetExpensesQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.expensesService.findMyMasjidExpenses(query, request.user);
  }

  @Post('my-masjid')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: "Create current masjid's expense" })
  @ApiBody({ type: CreateExpenseDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Expense created successfully',
  })
  create(@Body() dto: CreateExpenseDto, @Req() request: AuthenticatedRequest) {
    return this.expensesService.create(dto, request.user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get expense details' })
  @ApiParam({ name: 'id', example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Expense retrieved successfully',
  })
  findOne(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.expensesService.findOne(id, request.user);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Update an expense' })
  @ApiBody({ type: UpdateExpenseDto })
  update(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Body() dto: UpdateExpenseDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.expensesService.update(id, dto, request.user);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Cancel an expense' })
  cancel(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.expensesService.cancel(id, request.user);
  }
}
