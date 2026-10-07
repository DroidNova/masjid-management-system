import { ForbiddenException } from '@nestjs/common';
import { AuthenticatedUser } from '../auth/types/jwt-payload.type';
import { AdminService } from './admin.service';
import { AdminUserStatus } from './dto/update-user-status.dto';

// Admin endpoints are reachable only with platform.* permissions, which only
// SUPER_ADMIN holds (see src/access/permissions.ts and its spec). These tests
// cover the extra rules inside the service.
describe('AdminService', () => {
  const mockPrisma = {
    user: { findUnique: jest.fn(), update: jest.fn() },
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

    await expect(
      service.updateUserStatus(
        'other-super',
        { status: AdminUserStatus.SUSPENDED },
        superAdmin,
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
    expect(mockPrisma.user.update).not.toHaveBeenCalled();
  });

  it('updates the status of a committee member', async () => {
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'cm-1',
      userRoles: [{ role: { name: 'COMMITTEE_MEMBER' } }],
    });
    mockPrisma.user.update.mockResolvedValue({
      id: 'cm-1',
      status: 'SUSPENDED',
    });

    await expect(
      service.updateUserStatus(
        'cm-1',
        { status: AdminUserStatus.SUSPENDED },
        superAdmin,
      ),
    ).resolves.toEqual({ id: 'cm-1', status: 'SUSPENDED' });
    expect(mockAudit.record).toHaveBeenCalledWith(
      expect.objectContaining({
        entity: 'USER',
        action: 'STATUS_CHANGE',
        entityId: 'cm-1',
      }),
      mockPrisma,
    );
  });

  it.each([['SUPER_ADMIN'], ['MASJID_ADMIN']])(
    'refuses to assign %s',
    async (role) => {
      mockPrisma.user.findUnique.mockResolvedValue({
        id: 'u-1',
        userRoles: [{ role: { name: 'MEMBER' } }],
      });

      await expect(
        service.assignRoles('u-1', { roleNames: ['MEMBER', role] }, superAdmin),
      ).rejects.toBeInstanceOf(ForbiddenException);
      expect(mockPrisma.$transaction).not.toHaveBeenCalled();
    },
  );

  it('replaces roles in one transaction', async () => {
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'u-1',
      userRoles: [{ role: { name: 'MEMBER' } }],
    });
    mockRolesService.validateRoleNames.mockResolvedValue([
      { id: 'role-imam', name: 'IMAM' },
    ]);
    jest
      .spyOn(service, 'getUserById')
      .mockResolvedValue({ id: 'u-1' } as never);

    await service.assignRoles('u-1', { roleNames: ['imam'] }, superAdmin);

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
});
