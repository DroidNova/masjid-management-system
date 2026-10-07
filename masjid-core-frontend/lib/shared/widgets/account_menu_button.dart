import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:masjid_core_frontend/core/permissions/permission_helper.dart';
import 'package:masjid_core_frontend/core/storage/session_storage.dart';
import 'package:masjid_core_frontend/features/auth/data/auth_repository.dart';
import 'package:masjid_core_frontend/features/community/data/community_repository.dart';

/// App bar menu with account actions. Today: "Leave masjid", shown to users
/// with the `masjid.leave` permission.
///
/// One phone number can belong to one masjid at a time, so a person must
/// leave their current masjid before another masjid's committee can add them.
class AccountMenuButton extends StatefulWidget {
  const AccountMenuButton({
    super.key,
    CommunityRepository? communityRepository,
    AuthRepository? authRepository,
    SessionStorage? sessionStorage,
  }) : _communityRepository = communityRepository,
       _authRepository = authRepository,
       _sessionStorage = sessionStorage;

  final CommunityRepository? _communityRepository;
  final AuthRepository? _authRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<AccountMenuButton> createState() => _AccountMenuButtonState();
}

class _AccountMenuButtonState extends State<AccountMenuButton> {
  late final CommunityRepository _communityRepository =
      widget._communityRepository ?? CommunityRepository();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  bool _canLeave = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    setState(() {
      _canLeave =
          PermissionHelper.has(user, AppPermissions.masjidLeave) &&
          (user?.masjidId?.isNotEmpty ?? false);
    });
  }

  Future<void> _confirmLeave() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave masjid?'),
        content: const Text(
          'You will stop seeing this masjid and any imam or committee role '
          'you have here will end. Your payment history is kept. '
          'Another masjid can add you after you leave.\n\n'
          'You will be logged out.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave masjid'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await _communityRepository.leaveMyMasjid();
      await _authRepository.logout();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have left the masjid.')),
      );
      context.go('/auth');
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canLeave) return const SizedBox.shrink();
    if (_busy) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return PopupMenuButton<String>(
      tooltip: 'Account',
      onSelected: (value) {
        if (value == 'leave') _confirmLeave();
      },
      itemBuilder: (context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'leave',
          child: ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Leave masjid'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}
