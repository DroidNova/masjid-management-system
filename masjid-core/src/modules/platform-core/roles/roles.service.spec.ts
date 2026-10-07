import { RolesService } from './roles.service';

describe('RolesService', () => {
  const seeded = [
    { id: 'r-imam', name: 'IMAM' },
    { id: 'r-cm', name: 'COMMITTEE_MEMBER' },
    { id: 'r-member', name: 'MEMBER' },
  ];

  function setup(rows = seeded) {
    const prisma = { role: { findMany: jest.fn().mockResolvedValue(rows) } };
    return { prisma, service: new RolesService(prisma as never) };
  }

  it('reads the roles once and answers later calls from memory', async () => {
    const { prisma, service } = setup();

    await expect(
      service.validateRoleNames(['IMAM', 'IMAM', 'MEMBER']),
    ).resolves.toEqual([
      { id: 'r-imam', name: 'IMAM' },
      { id: 'r-member', name: 'MEMBER' },
    ]);
    await service.validateRoleNames(['COMMITTEE_MEMBER']);
    await expect(service.getRoleId('IMAM')).resolves.toBe('r-imam');

    expect(prisma.role.findMany).toHaveBeenCalledTimes(1);
  });

  it('rejects names that are not roles without a query', async () => {
    const { prisma, service } = setup();
    await expect(service.validateRoleNames(['KING'])).rejects.toMatchObject({
      response: expect.objectContaining({ errorCode: 'ROLE_NOT_FOUND' }),
    });
    expect(prisma.role.findMany).not.toHaveBeenCalled();
  });

  it('re-reads once when a role is missing (seed ran later)', async () => {
    const { prisma, service } = setup();
    await expect(
      service.validateRoleNames(['SUPER_ADMIN']),
    ).rejects.toMatchObject({
      response: expect.objectContaining({ errorCode: 'ROLE_NOT_FOUND' }),
    });
    expect(prisma.role.findMany).toHaveBeenCalledTimes(2);
  });
});
