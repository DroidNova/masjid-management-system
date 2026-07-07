import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';

export type OtpChallenge = {
  challengeId: string;
  phone: string;
  passwordVerified: boolean;
  expiresAt: Date;
  attempts: number;
  used: boolean;
};

@Injectable()
export class OtpChallengeService {
  private readonly challenges = new Map<string, OtpChallenge>();
  private readonly expiresInMs = 5 * 60 * 1000;
  private readonly maxAttempts = 5;

  // TODO: Replace in-memory OTP challenge store with Redis/DB-backed OTP store before production.
  create(phone: string, passwordVerified = false): OtpChallenge {
    this.cleanupExpired();

    const challenge: OtpChallenge = {
      challengeId: randomUUID(),
      phone,
      passwordVerified,
      expiresAt: new Date(Date.now() + this.expiresInMs),
      attempts: 0,
      used: false,
    };

    this.challenges.set(challenge.challengeId, challenge);
    return challenge;
  }

  get(challengeId: string): OtpChallenge | null {
    const challenge = this.challenges.get(challengeId);

    if (!challenge) return null;

    if (challenge.expiresAt.getTime() <= Date.now()) {
      this.challenges.delete(challengeId);
      return null;
    }

    return challenge;
  }

  incrementAttempts(challengeId: string): number {
    const challenge = this.challenges.get(challengeId);
    if (!challenge) return 0;

    challenge.attempts += 1;

    if (challenge.attempts >= this.maxAttempts) {
      this.challenges.delete(challengeId);
    }

    return challenge.attempts;
  }

  isMaxAttemptsReached(attempts: number): boolean {
    return attempts >= this.maxAttempts;
  }

  remove(challengeId: string): void {
    this.challenges.delete(challengeId);
  }

  private cleanupExpired(): void {
    const now = Date.now();
    for (const [challengeId, challenge] of this.challenges.entries()) {
      if (challenge.used || challenge.expiresAt.getTime() <= now) {
        this.challenges.delete(challengeId);
      }
    }
  }
}
