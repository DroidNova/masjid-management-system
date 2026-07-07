export type JwtPayload = {
  sub: string;
};

export type AuthenticatedUser = {
  id: string;
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
