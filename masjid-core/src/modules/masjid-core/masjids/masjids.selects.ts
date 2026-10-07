import { Prisma } from '../../../generated/prisma/client';

/** The imam as shown on the masjid profile. */
const imamUserSelect = {
  id: true,
  fullName: true,
  phone: true,
} as const satisfies Prisma.UserSelect;

export const masjidProfileSelect = {
  id: true,
  name: true,
  country: true,
  locality: true,
  district: true,
  state: true,
  address: true,
  contactNo: true,
  description: true,
  welcomeMsg: true,
  status: true,
  createdAt: true,
  updatedAt: true,
  imamUser: { select: imamUserSelect },
  namazTime: {
    select: {
      id: true,
      fajr: true,
      zuhr: true,
      asr: true,
      maghrib: true,
      isha: true,
      jumma: true,
      note: true,
    },
  },
  announcements: {
    where: { isActive: true },
    orderBy: { createdAt: 'desc' },
    take: 3,
    select: {
      id: true,
      title: true,
      message: true,
      createdAt: true,
    },
  },
} as const satisfies Prisma.MasjidSelect;

export const masjidWelcomeSelect = {
  id: true,
  name: true,
  welcomeMsg: true,
  updatedAt: true,
} as const satisfies Prisma.MasjidSelect;

const userRoleNamesSelect = {
  select: { role: { select: { name: true } } },
} as const;

/** Returned when a user is created or linked (no timestamps). */
export const masjidUserCreateSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  fatherName: true,
  age: true,
  gender: true,
  isFamilyHead: true,
  familyMemberCount: true,
  status: true,
  masjidId: true,
  userRoles: userRoleNamesSelect,
} as const satisfies Prisma.UserSelect;

export const masjidMemberSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
  fatherName: true,
  age: true,
  gender: true,
  isFamilyHead: true,
  familyMemberCount: true,
  status: true,
  masjidId: true,
  createdAt: true,
  updatedAt: true,
  userRoles: userRoleNamesSelect,
} as const satisfies Prisma.UserSelect;

/** Enough of an existing user to decide whether they can join a masjid. */
export const existingUserByPhoneSelect = {
  id: true,
  masjidId: true,
  userRoles: userRoleNamesSelect,
} as const satisfies Prisma.UserSelect;

export type MasjidProfile = Prisma.MasjidGetPayload<{
  select: typeof masjidProfileSelect;
}>;
export type MasjidWelcome = Prisma.MasjidGetPayload<{
  select: typeof masjidWelcomeSelect;
}>;
export type CreatedMasjidUser = Prisma.UserGetPayload<{
  select: typeof masjidUserCreateSelect;
}>;
export type MasjidMember = Prisma.UserGetPayload<{
  select: typeof masjidMemberSelect;
}>;
export type ExistingUserByPhone = Prisma.UserGetPayload<{
  select: typeof existingUserByPhoneSelect;
}>;

export type CreatedMasjidUserResponse = Omit<
  CreatedMasjidUser,
  'masjidId' | 'userRoles'
> & {
  masjidId: string;
  roles: string[];
  temporaryPassword?: string;
  message?: string;
};

export type MasjidMemberResponse = Omit<
  MasjidMember,
  'masjidId' | 'userRoles'
> & {
  masjidId: string;
  roles: string[];
};
