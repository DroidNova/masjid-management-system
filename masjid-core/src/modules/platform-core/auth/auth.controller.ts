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
import { Request } from 'express';
import { SuccessResponseDto } from '../../../common/dto/success-response.dto';
import { AuthService } from './auth.service';
import { AuthResponseDto, AuthUserDto } from './dto/auth-response.dto';
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
    timestamp: '2026-04-01T00:00:00.000Z',
    path: '/api/v1/auth/login',
  },
};

@ApiTags('Auth')
@ApiExtraModels(SuccessResponseDto, AuthResponseDto, AuthUserDto)
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login/start')
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
  startLogin(@Body() loginStartDto: LoginStartDto) {
    return this.authService.startLogin(loginStartDto);
  }

  @Post('login/password')
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
  verifyPassword(@Body() loginPasswordDto: LoginPasswordDto) {
    return this.authService.verifyPassword(loginPasswordDto);
  }

  @Post('login/verify-otp')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Verify OTP challenge and issue tokens' })
  @ApiBody({ type: VerifyOtpDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'OTP verified and tokens issued',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        { properties: { data: { $ref: '#/components/schemas/AuthResponseDto' } } },
      ],
    },
  })
  @ApiResponse({
    status: HttpStatus.UNAUTHORIZED,
    description: 'Invalid OTP or challenge',
    schema: standardErrorSchema,
  })
  verifyOtp(@Body() verifyOtpDto: VerifyOtpDto, @Req() req: Request) {
    return this.authService.verifyOtp(verifyOtpDto, req.get('user-agent'));
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Refresh access token using refresh token' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Token refresh successful',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        { properties: { data: { $ref: '#/components/schemas/AuthResponseDto' } } },
      ],
    },
  })
  refresh(@Body() refreshTokenDto: RefreshTokenDto) {
    return this.authService.refreshToken(refreshTokenDto);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Invalidate a refresh token session' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Logout successful',
    schema: {
      allOf: [
        { $ref: '#/components/schemas/SuccessResponseDto' },
        { properties: { data: { type: 'object', example: { loggedOut: true } } } },
      ],
    },
  })
  logout(@Body() refreshTokenDto: RefreshTokenDto) {
    return this.authService.logout(refreshTokenDto);
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
