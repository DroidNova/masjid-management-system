import {
  Body,
  Controller,
  Get,
  HttpStatus,
  Param,
  Patch,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiExtraModels,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { PaginatedResponseDto } from '../../../common/dto/paginated-response.dto';
import { SuccessResponseDto } from '../../../common/dto/success-response.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { AdminService } from './admin.service';
import {
  ListAdminMasjidsDto,
  UpdateMasjidStatusDto,
} from './dto/admin-masjids.dto';
import { AssignUserRolesDto } from './dto/assign-user-roles.dto';
import { ListAdminUsersDto } from './dto/list-admin-users.dto';
import { UpdateUserStatusDto } from './dto/update-user-status.dto';
import { PERMISSIONS } from '../../../access/permissions';
import { RequirePermissions } from '../../../access/require-permissions';

type AuthenticatedRequest = {
  user: AuthenticatedUser;
};

const standardErrorSchema = {
  example: {
    success: false,
    statusCode: 403,
    message: 'Forbidden resource',
    timestamp: '2026-04-01T00:00:00.000Z',
    path: '/api/v1/admin/users',
  },
};

@ApiTags('Admin')
@ApiBearerAuth('bearer')
@ApiExtraModels(SuccessResponseDto, PaginatedResponseDto)
@Controller('admin/users')
@UseGuards(JwtAuthGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get()
  @RequirePermissions(PERMISSIONS.PLATFORM_USERS_READ)
  @ApiOperation({ summary: 'Get users with pagination and optional search' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 10 })
  @ApiQuery({ name: 'search', required: false, example: 'alex' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Users retrieved successfully',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        {
          properties: {
            data: { $ref: '#/components/schemas/PaginatedResponseDto' },
          },
        },
      ],
    },
  })
  @ApiResponse({ status: HttpStatus.FORBIDDEN, schema: standardErrorSchema })
  listUsers(@Query() query: ListAdminUsersDto) {
    return this.adminService.listUsers(query);
  }

  @Get(':id')
  @RequirePermissions(PERMISSIONS.PLATFORM_USERS_READ)
  @ApiOperation({ summary: 'Get user by id' })
  @ApiParam({ name: 'id', example: 'usr_01HXYZ123' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'User retrieved successfully',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        {
          properties: {
            data: {
              type: 'object',
              example: {
                id: 'usr_01HXYZ123',
                fullName: 'Alex Johnson',
                status: 'ACTIVE',
              },
            },
          },
        },
      ],
    },
  })
  getUserById(@Param('id') id: string) {
    return this.adminService.getUserById(id);
  }

  @Patch(':id/status')
  @RequirePermissions(PERMISSIONS.PLATFORM_USERS_MANAGE)
  @ApiOperation({ summary: 'Update user status' })
  @ApiParam({ name: 'id', example: 'usr_01HXYZ123' })
  @ApiBody({ type: UpdateUserStatusDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'User status updated successfully',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        {
          properties: {
            data: {
              type: 'object',
              example: { id: 'usr_01HXYZ123', status: 'SUSPENDED' },
            },
          },
        },
      ],
    },
  })
  updateUserStatus(
    @Param('id') id: string,
    @Body() dto: UpdateUserStatusDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.adminService.updateUserStatus(id, dto, request.user);
  }

  @Post(':id/roles')
  @RequirePermissions(PERMISSIONS.PLATFORM_ROLES_ASSIGN)
  @ApiOperation({ summary: 'Assign roles to a user' })
  @ApiParam({ name: 'id', example: 'usr_01HXYZ123' })
  @ApiBody({ type: AssignUserRolesDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Roles assigned successfully',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        {
          properties: {
            data: {
              type: 'object',
              example: {
                id: 'usr_01HXYZ123',
                roles: ['MASJID_ADMIN', 'IMAM'],
              },
            },
          },
        },
      ],
    },
  })
  assignRoles(
    @Param('id') id: string,
    @Body() dto: AssignUserRolesDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.adminService.assignRoles(id, dto, request.user);
  }
}

@ApiTags('Admin Dashboard')
@ApiBearerAuth('bearer')
@Controller('admin/dashboard')
@UseGuards(JwtAuthGuard)
export class AdminDashboardController {
  constructor(private readonly adminService: AdminService) {}

  @Get('summary')
  @RequirePermissions(PERMISSIONS.PLATFORM_USERS_READ)
  @ApiOperation({ summary: 'Get optimized super admin dashboard summary' })
  getSummary() {
    return this.adminService.getDashboardSummary();
  }
}

@ApiTags('Admin Masjids')
@ApiBearerAuth('bearer')
@Controller('admin/masjids')
@UseGuards(JwtAuthGuard)
export class AdminMasjidsController {
  constructor(private readonly adminService: AdminService) {}

  @Get()
  @RequirePermissions(PERMISSIONS.PLATFORM_MASJIDS_MANAGE)
  @ApiOperation({ summary: 'Get masjids with pagination and filters' })
  listMasjids(@Query() query: ListAdminMasjidsDto) {
    return this.adminService.listMasjids(query);
  }

  @Get(':id')
  @RequirePermissions(PERMISSIONS.PLATFORM_MASJIDS_MANAGE)
  @ApiOperation({ summary: 'Get masjid details by id' })
  getMasjid(@Param('id') id: string) {
    return this.adminService.getMasjidById(id);
  }

  @Patch(':id/status')
  @RequirePermissions(PERMISSIONS.PLATFORM_MASJIDS_MANAGE)
  @ApiOperation({ summary: 'Update masjid status' })
  updateMasjidStatus(
    @Param('id') id: string,
    @Body() dto: UpdateMasjidStatusDto,
  ) {
    return this.adminService.updateMasjidStatus(id, dto);
  }
}
