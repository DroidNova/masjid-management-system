import { getLogUser } from './log-user.util';

describe('getLogUser', () => {
  it('accepts request objects without an authenticated user', () => {
    expect(getLogUser({ method: 'GET', url: '/health' })).toEqual({});
  });

  it('extracts the authenticated user id and roles when present', () => {
    expect(
      getLogUser({
        method: 'GET',
        user: { id: 'user-1', roles: ['MEMBER'] },
      }),
    ).toEqual({ userId: 'user-1', roles: ['MEMBER'] });
  });

  it('safely handles non-object callback values', () => {
    expect(getLogUser(undefined)).toEqual({});
  });
});
