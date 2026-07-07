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
  CreateImamSalaryDto,
  PaymentStatusDto,
} from './dto/create-imam-salary.dto';
import { GetImamSalariesQueryDto } from './dto/get-imam-salaries-query.dto';
import { UpdateImamSalaryDto } from './dto/update-imam-salary.dto';
import { ImamSalariesService } from './imam-salaries.service';

type AuthenticatedRequest = {
  user: AuthenticatedUser;
};

const standardErrorSchema = {
  example: {
    success: false,
    message: 'Current user is not assigned to a masjid',
    errorCode: 'USER_MASJID_NOT_ASSIGNED',
  },
};

@ApiTags('Imam Salaries')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('imam-salaries')
export class ImamSalariesController {
  constructor(private readonly imamSalariesService: ImamSalariesService) {}

  @Get('my-masjid')
  @ApiOperation({ summary: "Get current masjid's imam salary records" })
  @ApiQuery({ name: 'status', required: false, enum: PaymentStatusDto })
  @ApiQuery({ name: 'month', required: false, type: Number, example: 6 })
  @ApiQuery({ name: 'year', required: false, type: Number, example: 2026 })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Imam salary records retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  findMyMasjidSalaries(
    @Query() query: GetImamSalariesQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.imamSalariesService.findMyMasjidSalaries(query, request.user);
  }

  @Post('my-masjid')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: "Create current masjid's imam salary record" })
  @ApiBody({ type: CreateImamSalaryDto })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Imam salary record created successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  create(
    @Body() dto: CreateImamSalaryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.imamSalariesService.create(dto, request.user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get imam salary record details' })
  @ApiParam({
    name: 'id',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Imam salary record retrieved successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  findOne(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.imamSalariesService.findOne(id, request.user);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Update an imam salary record' })
  @ApiParam({
    name: 'id',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiBody({ type: UpdateImamSalaryDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Imam salary record updated successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  update(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Body() dto: UpdateImamSalaryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.imamSalariesService.update(id, dto, request.user);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('MASJID_ADMIN', 'COMMITTEE_MEMBER')
  @ApiOperation({ summary: 'Delete an imam salary record' })
  @ApiParam({
    name: 'id',
    example: '4e0798d2-3fd3-4caa-9966-9f85c96f8b2f',
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Imam salary record deleted successfully',
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, schema: standardErrorSchema })
  remove(
    @Param('id', new ParseUUIDPipe({ version: '4' })) id: string,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.imamSalariesService.remove(id, request.user);
  }
}
