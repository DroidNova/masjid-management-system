import { Prisma } from '../../../generated/prisma/client';

const basicUserSelect = {
  id: true,
  fullName: true,
  email: true,
  phone: true,
} as const satisfies Prisma.UserSelect;

/** A user found or created while approving a request. */
export const requestUserSelect = {
  ...basicUserSelect,
  masjidId: true,
  fatherName: true,
  age: true,
  gender: true,
  isFamilyHead: true,
  familyMemberCount: true,
} as const satisfies Prisma.UserSelect;

export const createdMasjidSelect = {
  id: true,
  name: true,
  status: true,
  createdAt: true,
} as const satisfies Prisma.MasjidSelect;

/** Used for both the list and the single-request responses. */
export const masjidRequestSelect = {
  id: true,
  requestedById: true,
  reviewedById: true,
  requesterName: true,
  requesterPhone: true,
  requesterEmail: true,
  status: true,
  masjidName: true,
  locality: true,
  district: true,
  country: true,
  state: true,
  address: true,
  contactNo: true,
  description: true,
  welcomeMsg: true,
  imamName: true,
  imamEmail: true,
  imamPhone: true,
  imamAddress: true,
  imamFatherName: true,
  imamAge: true,
  imamGender: true,
  committeeMembers: true,
  rejectionReason: true,
  reviewedAt: true,
  createdMasjidId: true,
  createdAt: true,
  updatedAt: true,
  requestedBy: { select: basicUserSelect },
  reviewedBy: { select: basicUserSelect },
  createdMasjid: { select: createdMasjidSelect },
} as const satisfies Prisma.MasjidRegistrationRequestSelect;

/** Public status lookup by the requester's phone. */
export const masjidRequestTrackingSelect = {
  masjidName: true,
  status: true,
  imamName: true,
  createdAt: true,
  reviewedAt: true,
} as const satisfies Prisma.MasjidRegistrationRequestSelect;

export type RequestUser = Prisma.UserGetPayload<{
  select: typeof requestUserSelect;
}>;

export type MasjidRequestRecord = Prisma.MasjidRegistrationRequestGetPayload<{
  select: typeof masjidRequestSelect;
}>;
