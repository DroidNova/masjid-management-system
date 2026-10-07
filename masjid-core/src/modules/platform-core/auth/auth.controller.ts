import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiBody,
  ApiExtraModels,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { Request } from 'express';
import { RATE_LIMITS } from '../../../common/rate-limit/rate-limit';
import { SuccessResponseDto } from '../../../common/dto/success-response.dto';
import { AuthService } from './auth.service';
import { AuthResponseDto, AuthUserDto } from './dto/auth-response.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { LoginPasswordDto } from './dto/login-password.dto';
import { LoginStartDto } from './dto/login-start.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { AuthenticatedUser } from './types/jwt-payload.type';

type AuthenticatedRequest = Request & {
  user: AuthenticatedUser;
};

const standardErrorSchema = {
  example: {
    success: false,
    statusCode: 400,
    message: 'Error message',
    errorCode: 'INVALID_CREDENTIALS',
    requestId: '6f1c2c8e-5d1b-4a8e-9f0e-0f2a1b3c4d5e',
  },
};

@ApiTags('Auth')
@ApiExtraModels(SuccessResponseDto, AuthResponseDto, AuthUserDto)
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login/start')
  @Throttle(RATE_LIMITS.login)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Start phone-first login and determine next step' })
  @ApiBody({ type: LoginStartDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Login next step resolved',
    schema: {
      example: {
        success: true,
        message: 'Request successful',
        data: {
          nextStep: 'OTP_REQUIRED',
          challengeId: 'd0f5ec4c-7d04-4bb0-b481-efc2cd981a63',
          otpLength: 4,
          phone: '9876543210',
          message: 'OTP sent successfully',
        },
      },
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'Invalid credentials',
    schema: standardErrorSchema,
  })
  @ApiResponse({
    status: HttpStatus.FORBIDDEN,
    description: 'Account is inactive or suspended (USER_INACTIVE)',
    schema: standardErrorSchema,
  })
  startLogin(@Body() loginStartDto: LoginStartDto) {
    return this.authService.startLogin(loginStartDto);
  }

  @Post('login/password')
  @Throttle(RATE_LIMITS.login)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify password for privileged phone login' })
  @ApiBody({ type: LoginPasswordDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Password accepted and OTP challenge created',
    schema: {
      example: {
        success: true,
        message: 'Request successful',
        data: {
          nextStep: 'OTP_REQUIRED',
          challengeId: 'd0f5ec4c-7d04-4bb0-b481-efc2cd981a63',
          otpLength: 4,
          phone: '9876543210',
          message: 'OTP sent successfully',
        },
      },
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'Invalid credentials',
    schema: standardErrorSchema,
  })
  @ApiResponse({
    status: HttpStatus.FORBIDDEN,
    description:
      'Member account (PASSWORD_LOGIN_NOT_ALLOWED_FOR_MEMBER), or correct password for an inactive account (USER_INACTIVE)',
    schema: standardErrorSchema,
  })
  verifyPassword(@Body() loginPasswordDto: LoginPasswordDto) {
    return this.authService.verifyPassword(loginPasswordDto);
  }

  @Post('login/verify-otp')
  @Throttle(RATE_LIMITS.login)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP challenge and issue tokens' })
  @ApiBody({ type: VerifyOtpDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'OTP verified and tokens issued',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        {
          properties: {
            data: { $ref: '#/components/schemas/AuthResponseDto' },
          },
        },
      ],
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'Invalid OTP or challenge',
    schema: standardErrorSchema,
  })
  verifyOtp(@Body() verifyOtpDto: VerifyOtpDto, @Req() req: Request) {
    return this.authService.verifyOtp(
      verifyOtpDto,
      req.get('user-agent'),
      req.ip,
    );
  }

  @Post('refresh')
  @Throttle(RATE_LIMITS.refresh)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Rotate the refresh token and issue a new access token',
    description:
      'Each refresh token works once. Reusing an old one signs the session out (errorCode SESSION_REVOKED). A deactivated or suspended account gets 403 USER_INACTIVE and its session is ended.',
  })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Token refresh successful',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        {
          properties: {
            data: { $ref: '#/components/schemas/AuthResponseDto' },
          },
        },
      ],
    },
  })
  refresh(@Body() refreshTokenDto: RefreshTokenDto) {
    return this.authService.refreshToken(refreshTokenDto);
  }

  @Post('logout')
  @Throttle(RATE_LIMITS.refresh)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Invalidate a refresh token session',
    description:
      'Always succeeds with data null, also for an invalid or already ended refresh token.',
  })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Logout successful',
    schema: {
      example: {
        success: true,
        message: 'Logged out successfully',
        data: null,
      },
    },
  })
  logout(@Body() refreshTokenDto: RefreshTokenDto) {
    return this.authService.logout(refreshTokenDto);
  }

  @Post('logout-all')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('bearer')
  @ApiOperation({ summary: 'Sign out every session of the current user' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'All sessions revoked',
    schema: {
      example: {
        success: true,
        message: 'Request successful',
        data: { revokedSessions: 3 },
      },
    },
  })
  logoutAll(@Req() req: AuthenticatedRequest) {
    return this.authService.logoutAll(req.user);
  }

  @Post('password/change')
  @UseGuards(JwtAuthGuard)
  @Throttle(RATE_LIMITS.passwordChange)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('bearer')
  @ApiOperation({
    summary: 'Change the password of an imam, committee member or admin',
    description:
      'Requires the current password. Other sessions are signed out; the current one stays valid. Members have no password (403 PASSWORD_CHANGE_NOT_ALLOWED).',
  })
  @ApiBody({ type: ChangePasswordDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Password changed',
    schema: {
      example: {
        success: true,
        message: 'Request successful',
        data: { passwordChanged: true, otherSessionsSignedOut: 1 },
      },
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'Current password is incorrect',
    schema: standardErrorSchema,
  })
  changePassword(
    @Req() req: AuthenticatedRequest,
    @Body() dto: ChangePasswordDto,
  ) {
    return this.authService.changePassword(req.user, dto);
  }

  @Get('me')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('bearer')
  @ApiOperation({ summary: 'Get currently authenticated user profile' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Current user fetched successfully',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        { properties: { data: { $ref: '#/components/schemas/AuthUserDto' } } },
      ],
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'Access token is missing or invalid',
    schema: standardErrorSchema,
  })
  me(@Req() req: AuthenticatedRequest) {
    return req.user;
  }
}
