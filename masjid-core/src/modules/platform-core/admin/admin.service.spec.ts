import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { AdminService } from './admin.service';
import { AdminUserStatus } from './dto/update-user-status.dto';
import { MasjidStatus } from '../../../generated/prisma/enums';

async function expectCode(promise: Promise<unknown>, errorCode: string) {
  await expect(promise).rejects.toMatchObject({
    response: expect.objectContaining({ errorCode }),
  });
}

// Admin endpoints are reachable only with platform.* permissions, which only
// SUPER_ADMIN holds (see src/access/permissions.ts and its spec). These tests
// cover the extra rules inside the service.
describe('AdminService', () => {
  const mockPrisma = {
    user: {
      findUnique: jest.fn(),
      update: jest.fn(),
      groupBy: jest.fn(),
    },
    masjid: { findUnique: jest.fn(), update: jest.fn(), groupBy: jest.fn() },
    masjidRegistrationRequest: { groupBy: jest.fn() },
    session: { deleteMany: jest.fn() },
    userRole: { deleteMany: jest.fn(), createMany: jest.fn() },
    $transaction: jest.fn(
      (arg: unknown): Promise<unknown> =>
        typeof arg === 'function'
          ? Promise.resolve((arg as (tx: unknown) => unknown)(mockPrisma))
          : Promise.all(arg as Promise<unknown>[]),
    ),
  };
  const mockRolesService = { validateRoleNames: jest.fn() };
  const mockAudit = { record: jest.fn() };
  const service = new AdminService(
    mockPrisma as never,
    mockRolesService as never,
    mockAudit as never,
  );
  const superAdmin = {
    id: 'super-admin',
    roles: ['SUPER_ADMIN'],
  } as AuthenticatedUser;

  beforeEach(() => jest.clearAllMocks());

  it('does not let anyone change a SUPER_ADMIN account', async () => {
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'other-super',
      userRoles: [{ role: { name: 'SUPER_ADMIN' } }],
    });

    await expectCode(
      service.updateUserStatus(
        'other-super',
        { status: AdminUserStatus.SUSPENDED },
        superAdmin,
      ),
      'SUPER_ADMIN_IMMUTABLE',
    );
    expect(mockPrisma.user.update).not.toHaveBeenCalled();
  });

  it('returns USER_NOT_FOUND for an unknown user', async () => {
    mockPrisma.user.findUnique.mockResolvedValue(null);
    await expectCode(
      service.updateUserStatus(
        'missing',
        { status: AdminUserStatus.ACTIVE },
        superAdmin,
      ),
      'USER_NOT_FOUND',
    );
  });

  it('suspends a committee member and signs them out everywhere', async () => {
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'cm-1',
      userRoles: [{ role: { name: 'COMMITTEE_MEMBER' } }],
    });
    mockPrisma.user.update.mockResolvedValue({
      id: 'cm-1',
      status: 'SUSPENDED',
    });
    mockPrisma.session.deleteMany.mockResolvedValue({ count: 2 });

    await expect(
      service.updateUserStatus(
        'cm-1',
        { status: AdminUserStatus.SUSPENDED },
        superAdmin,
      ),
    ).resolves.toEqual({ id: 'cm-1', status: 'SUSPENDED' });
    expect(mockPrisma.session.deleteMany).toHaveBeenCalledWith({
      where: { userId: 'cm-1' },
    });
    expect(mockAudit.record).toHaveBeenCalledWith(
      expect.objectContaining({
        entity: 'USER',
        action: 'STATUS_CHANGE',
        entityId: 'cm-1',
      }),
      mockPrisma,
    );
  });

  it('keeps sessions when re-activating a user', async () => {
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'cm-1',
      userRoles: [],
    });
    mockPrisma.user.update.mockResolvedValue({ id: 'cm-1', status: 'ACTIVE' });

    await service.updateUserStatus(
      'cm-1',
      { status: AdminUserStatus.ACTIVE },
      superAdmin,
    );
    expect(mockPrisma.session.deleteMany).not.toHaveBeenCalled();
  });

  it.each([['SUPER_ADMIN'], ['MASJID_ADMIN']])(
    'refuses to assign %s before reading the database',
    async (role) => {
      await expectCode(
        service.assignRoles('u-1', { roleNames: ['MEMBER', role] }, superAdmin),
        'ROLE_NOT_ASSIGNABLE',
      );
      expect(mockPrisma.user.findUnique).not.toHaveBeenCalled();
      expect(mockPrisma.$transaction).not.toHaveBeenCalled();
    },
  );

  it('replaces roles in one transaction and returns the user without re-reading', async () => {
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'u-1',
      fullName: 'User',
      masjidId: null,
      masjid: null,
      userRoles: [{ role: { name: 'MEMBER' } }],
    });
    mockRolesService.validateRoleNames.mockResolvedValue([
      { id: 'role-imam', name: 'IMAM' },
    ]);

    const result = await service.assignRoles(
      'u-1',
      { roleNames: ['imam'] },
      superAdmin,
    );

    expect(result).toMatchObject({ id: 'u-1', roles: ['IMAM'] });
    expect(mockPrisma.user.findUnique).toHaveBeenCalledTimes(1);
    expect(mockRolesService.validateRoleNames).toHaveBeenCalledWith(['IMAM']);
    expect(mockPrisma.$transaction).toHaveBeenCalledTimes(1);
    expect(mockPrisma.userRole.createMany).toHaveBeenCalledWith({
      data: [{ userId: 'u-1', roleId: 'role-imam' }],
      skipDuplicates: true,
    });
    expect(mockAudit.record).toHaveBeenCalledWith(
      expect.objectContaining({
        entity: 'USER',
        action: 'ROLES_CHANGE',
        before: { roles: ['MEMBER'] },
        after: { roles: ['IMAM'] },
      }),
      mockPrisma,
    );
  });

  it.each([[MasjidStatus.REJECTED], [MasjidStatus.SUSPENDED]])(
    'requires a reason to set a masjid %s',
    async (status) => {
      await expectCode(
        service.updateMasjidStatus('m-1', { status, reason: '  ' }, superAdmin),
        'VALIDATION_ERROR',
      );
      expect(mockPrisma.$transaction).not.toHaveBeenCalled();
    },
  );

  it('returns MASJID_NOT_FOUND for an unknown masjid', async () => {
    mockPrisma.masjid.findUnique.mockResolvedValue(null);
    await expectCode(
      service.updateMasjidStatus(
        'm-1',
        { status: MasjidStatus.APPROVED },
        superAdmin,
      ),
      'MASJID_NOT_FOUND',
    );
  });

  it('builds the dashboard summary from three grouped counts', async () => {
    mockPrisma.user.groupBy.mockResolvedValue([
      { status: 'ACTIVE', _count: { _all: 7 } },
      { status: 'SUSPENDED', _count: { _all: 1 } },
    ]);
    mockPrisma.masjid.groupBy.mockResolvedValue([
      { status: 'APPROVED', _count: { _all: 3 } },
      { status: 'REJECTED', _count: { _all: 2 } },
    ]);
    mockPrisma.masjidRegistrationRequest.groupBy.mockResolvedValue([
      { status: 'PENDING', _count: { _all: 4 } },
    ]);

    await expect(service.getDashboardSummary()).resolves.toEqual({
      totalUsers: 8,
      activeUsers: 7,
      inactiveUsers: 0,
      suspendedUsers: 1,
      totalMasjids: 5,
      approvedMasjids: 3,
      pendingMasjids: 0,
      suspendedMasjids: 0,
      pendingRequests: 4,
      approvedRequests: 0,
      rejectedRequests: 0,
    });
  });
});
