export type TokenType = 'access' | 'refresh';

/**
 * Claims inside both tokens. `sid` ties a token to one Session row, so a
 * session can be revoked (logout, logout-all, password change) and refresh
 * token reuse can be detected.
 */
export type JwtPayload = {
  sub: string;
  sid: string;
  typ: TokenType;
  /** Random id so two refresh tokens issued in the same second differ. */
  jti?: string;
};

export type AuthenticatedUser = {
  id: string;
  /** Session the current access token belongs to. */
  sessionId: string;
  fullName: string;
  email: string | null;
  phone: string | null;
  masjidId: string | null;
  status: string;
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  createdAt: Date;
  updatedAt: Date;
  roles: string[];
  permissions: string[];
};
