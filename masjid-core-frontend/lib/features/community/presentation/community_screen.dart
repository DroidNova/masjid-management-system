import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/refresh/app_data_refresh_bus.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/auth/data/auth_repository.dart';
import 'package:platform_core_frontend/features/auth/data/models/app_user.dart';
import 'package:platform_core_frontend/features/community/data/community_repository.dart';
import 'package:platform_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:platform_core_frontend/features/community/data/models/masjid_detail_model.dart';
import 'package:platform_core_frontend/features/community/data/models/update_community_user_request.dart';
import 'package:platform_core_frontend/features/community/presentation/widgets/community_section.dart';
import 'package:platform_core_frontend/features/community/presentation/widgets/masjid_info_card.dart';
import 'package:platform_core_frontend/shared/widgets/app_button.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({
    super.key,
    CommunityRepository? communityRepository,
    AuthRepository? authRepository,
    SessionStorage? sessionStorage,
  })  : _communityRepository = communityRepository,
        _authRepository = authRepository,
        _sessionStorage = sessionStorage;

  final CommunityRepository? _communityRepository;
  final AuthRepository? _authRepository;
  final SessionStorage? _sessionStorage;

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  late final CommunityRepository _communityRepository =
      widget._communityRepository ?? CommunityRepository();
  late final AuthRepository _authRepository =
      widget._authRepository ?? AuthRepository();
  late final SessionStorage _sessionStorage =
      widget._sessionStorage ?? SessionStorage();

  MasjidDetailModel? _masjid;
  List<CommunityUserModel> _users = <CommunityUserModel>[];
  String? _errorMessage;
  bool _isLoading = true;
  bool _hasLoaded = false;
  Future<void>? _activeLoad;
  late final ValueNotifier<int> _refreshNotifier;
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _refreshNotifier =
        AppDataRefreshBus.instance.notifierFor(AppDataScope.community);
    _refreshNotifier.addListener(_onRefreshRequested);
    _loadCurrentUser();
    _loadCommunity();
  }

  @override
  void dispose() {
    _refreshNotifier.removeListener(_onRefreshRequested);
    super.dispose();
  }

  void _onRefreshRequested() {
    _loadCommunity(force: true);
  }

  Future<void> _loadCurrentUser() async {
    final user = await _sessionStorage.getUser();
    if (!mounted) return;
    setState(() => _currentUser = user);
  }

  Future<void> _loadCommunity({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;
    if (!force && _hasLoaded) return Future<void>.value();

    _activeLoad = _performLoadCommunity().whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoadCommunity() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait<Object>([
        _communityRepository.getMyMasjid(),
        _communityRepository.getMyMasjidUsers(),
      ]);
      if (!mounted) return;
      setState(() {
        _masjid = results[0] as MasjidDetailModel;
        _users = results[1] as List<CommunityUserModel>;
        _hasLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authRepository.logout();
    if (!mounted) return;
    context.go('/auth');
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  bool get _isUnauthorizedError {
    final message = _errorMessage?.toLowerCase() ?? '';
    return message.contains('unauthorized') || message.contains('401');
  }

  bool get _isNoMasjidError {
    final message = _errorMessage?.toLowerCase() ?? '';
    return message.contains('not assigned') || message.contains('masjid');
  }

  bool get _canAddUsers {
    final user = _currentUser;
    return user != null && PermissionHelper.canAddCommunityUser(user.roles);
  }

  Future<void> _openAddUser() async {
    await context.push('/community/add-user');
  }

  List<String> get _currentUserRoles => _currentUser?.roles ?? const <String>[];

  void _replaceUser(CommunityUserModel updatedUser) {
    setState(() {
      _users = _users
          .map((user) => user.id == updatedUser.id ? updatedUser : user)
          .toList();
    });
  }

  Future<void> _openEditUser(CommunityUserModel user) async {
    if (!PermissionHelper.canEditCommunityUser(
      currentUserRoles: _currentUserRoles,
      targetUserRoles: user.roles,
    )) {
      return;
    }
    final result = await showDialog<UpdateCommunityUserRequest>(
      context: context,
      builder: (context) => _EditCommunityUserDialog(user: user),
    );
    if (result == null) return;
    try {
      final updated = await _communityRepository.updateMasjidUser(user.id, result);
      if (!mounted) return;
      _replaceUser(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_cleanError(error))));
    }
  }

  Future<void> _openChangeUserStatus(CommunityUserModel user) async {
    if (!PermissionHelper.canChangeCommunityUserStatus(
      currentUserRoles: _currentUserRoles,
      targetUserRoles: user.roles,
    )) {
      return;
    }
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _StatusDialog(currentStatus: user.status),
    );
    if (result == null) return;
    try {
      final updated = await _communityRepository.updateMasjidUserStatus(user.id, result);
      if (!mounted) return;
      _replaceUser(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User status updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_cleanError(error))));
    }
  }

  List<CommunityUserModel> get _committeeUsers {
    return _users
        .where((user) => user.isMasjidAdmin || user.isCommitteeMember)
        .toList();
  }

  List<CommunityUserModel> get _imamUsers {
    return _users
        .where(
          (user) =>
              user.isImam && !user.isMasjidAdmin && !user.isCommitteeMember,
        )
        .toList();
  }

  List<CommunityUserModel> get _memberUsers {
    final groupedIds = <String>{
      ..._committeeUsers.map((user) => user.id),
      ..._imamUsers.map((user) => user.id),
    };
    return _users.where((user) => !groupedIds.contains(user.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();

    if (_errorMessage != null) {
      if (_isUnauthorizedError) {
        return _CommunityErrorView(
          message: 'Session expired. Please login again.',
          buttonLabel: 'Back to Login',
          onPressed: _logout,
        );
      }
      return _CommunityErrorView(
        message: _isNoMasjidError
            ? 'You are not assigned to any masjid yet.'
            : 'Unable to load community details.',
        detail: _isNoMasjidError ? null : _errorMessage,
        onPressed: () => _loadCommunity(force: true),
      );
    }

    final masjid = _masjid;
    if (masjid == null) {
      return _CommunityErrorView(
        message: 'Unable to load community details.',
        onPressed: () => _loadCommunity(force: true),
      );
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _loadCommunity(force: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Community',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    const Text('Masjid members and committee details'),
                    if (_canAddUsers) ...<Widget>[
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: _openAddUser,
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Add User'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    MasjidInfoCard(masjid: masjid),
                    const SizedBox(height: 12),
                    CommunitySection(
                      title: 'Imam',
                      users: _imamUsers,
                      emptyMessage: 'Imam is not added yet.',
                      currentUserRoles: _currentUserRoles,
                      onEditUser: _openEditUser,
                      onChangeUserStatus: _openChangeUserStatus,
                    ),
                    const SizedBox(height: 12),
                    CommunitySection(
                      title: 'Committee Members',
                      users: _committeeUsers,
                      emptyMessage: 'No committee members added yet.',
                      currentUserRoles: _currentUserRoles,
                      onEditUser: _openEditUser,
                      onChangeUserStatus: _openChangeUserStatus,
                    ),
                    const SizedBox(height: 12),
                    CommunitySection(
                      title: 'Members',
                      users: _memberUsers,
                      emptyMessage: 'No members added yet.',
                      currentUserRoles: _currentUserRoles,
                      onEditUser: _openEditUser,
                      onChangeUserStatus: _openChangeUserStatus,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityErrorView extends StatelessWidget {
  const _CommunityErrorView({
    required this.message,
    required this.onPressed,
    this.detail,
    this.buttonLabel = 'Retry',
  });

  final String message;
  final String? detail;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Icon(
                  Icons.groups_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (detail != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(detail!, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                AppButton(label: buttonLabel, onPressed: onPressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _EditCommunityUserDialog extends StatefulWidget {
  const _EditCommunityUserDialog({required this.user});
  final CommunityUserModel user;
  @override
  State<_EditCommunityUserDialog> createState() => _EditCommunityUserDialogState();
}

class _EditCommunityUserDialogState extends State<_EditCommunityUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.user.fullName);
  late final TextEditingController _phone = TextEditingController(text: widget.user.phone ?? '');
  late final TextEditingController _email = TextEditingController(text: widget.user.email ?? '');
  late final TextEditingController _fatherName = TextEditingController(text: widget.user.fatherName ?? '');
  late final TextEditingController _age = TextEditingController(text: widget.user.age?.toString() ?? '');
  late final TextEditingController _familyMemberCount = TextEditingController(text: widget.user.familyMemberCount?.toString() ?? '');
  late String? _gender = widget.user.gender;
  late bool _isFamilyHead = widget.user.isFamilyHead;

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _email.dispose(); _fatherName.dispose(); _age.dispose(); _familyMemberCount.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit user'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name *'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Full name is required' : null),
            TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone *'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Phone is required' : null),
            TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            TextFormField(controller: _fatherName, decoration: const InputDecoration(labelText: 'Father name *'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Father name is required' : null),
            TextFormField(controller: _age, decoration: const InputDecoration(labelText: 'Age *'), keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly], validator: (v) { final age = int.tryParse(v?.trim() ?? ''); if (age == null) return 'Age is required'; if (age < 1 || age > 120) return 'Age must be between 1 and 120'; return null; }),
            DropdownButtonFormField<String>(value: _gender, decoration: const InputDecoration(labelText: 'Gender *'), items: const <DropdownMenuItem<String>>[DropdownMenuItem(value: 'MALE', child: Text('Male')), DropdownMenuItem(value: 'FEMALE', child: Text('Female')), DropdownMenuItem(value: 'OTHER', child: Text('Other'))], onChanged: (value) => setState(() => _gender = value), validator: (value) => value == null ? 'Gender is required' : null),
            if (widget.user.isMember) SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Is Family Head *'), value: _isFamilyHead, onChanged: (value) => setState(() => _isFamilyHead = value)),
            if (widget.user.isMember && _isFamilyHead) TextFormField(controller: _familyMemberCount, decoration: const InputDecoration(labelText: 'Family Member Count'), keyboardType: TextInputType.number, inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.of(context).pop(UpdateCommunityUserRequest(fullName: _name.text, phone: _phone.text, email: _email.text, fatherName: _fatherName.text, age: int.parse(_age.text.trim()), gender: _gender!, isFamilyHead: widget.user.isMember ? _isFamilyHead : null, familyMemberCount: _familyMemberCount.text.trim().isEmpty ? null : int.parse(_familyMemberCount.text.trim())));
        }, child: const Text('Save')),
      ],
    );
  }
}

class _StatusDialog extends StatefulWidget {
  const _StatusDialog({this.currentStatus});
  final String? currentStatus;
  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  static const _statuses = <String>['ACTIVE', 'INACTIVE', 'SUSPENDED'];
  late String _status = _statuses.contains(widget.currentStatus) ? widget.currentStatus! : 'ACTIVE';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update status'),
      content: DropdownButtonFormField<String>(
        value: _status,
        items: _statuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
        onChanged: (value) => setState(() => _status = value ?? _status),
      ),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.of(context).pop(_status), child: const Text('Update')),
      ],
    );
  }
}
