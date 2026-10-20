import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { PERMISSIONS } from '../../../access/permissions';
import { RequirePermissions } from '../../../access/require-permissions';
import { PaginationQueryDto } from '../../../common/dto/pagination-query.dto';
import { JwtAuthGuard } from '../../platform-core/auth/guards/jwt-auth.guard';
import { AuthenticatedUser } from '../../platform-core/auth/types/jwt-payload.type';
import { NotificationsService } from './notifications.service';

type AuthenticatedRequest = { user: AuthenticatedUser };

@ApiTags('Notifications')
@ApiBearerAuth('bearer')
@UseGuards(JwtAuthGuard)
@Controller('notifications/my')
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Get()
  @RequirePermissions(PERMISSIONS.NOTIFICATIONS_READ)
  @ApiOperation({ summary: 'My notices, newest first' })
  listMine(
    @Query() query: PaginationQueryDto,
    @Req() request: AuthenticatedRequest,
  ) {
    return this.notifications.listMine(query, request.user);
  }

  @Get('unread-count')
  @RequirePermissions(PERMISSIONS.NOTIFICATIONS_READ)
  @ApiOperation({ summary: 'How many of my notices are not read yet' })
  unreadCount(@Req() request: AuthenticatedRequest) {
    return this.notifications.unreadCount(request.user);
  }

  @Post('read-all')
  @HttpCode(HttpStatus.OK)
  @RequirePermissions(PERMISSIONS.NOTIFICATIONS_READ)
  @ApiOperation({ summary: 'Mark all my notices as read' })
  markAllRead(@Req() request: AuthenticatedRequest) {
    return this.notifications.markAllRead(request.user);
  }
}
