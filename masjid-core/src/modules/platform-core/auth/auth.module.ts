import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { OtpService } from './services/otp.service';
import { AuthCleanupService } from './services/auth-cleanup.service';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    // Secrets are passed per call from AppConfig (access and refresh differ).
    JwtModule.register({}),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, OtpService, AuthCleanupService],
  exports: [AuthService],
})
export class AuthModule {}
