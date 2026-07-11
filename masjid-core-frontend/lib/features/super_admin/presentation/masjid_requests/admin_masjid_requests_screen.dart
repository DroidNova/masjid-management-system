import 'dart:async';

import 'package:flutter/material.dart';
import 'package:platform_core_frontend/features/super_admin/data/super_admin_repository.dart';
import 'package:platform_core_frontend/features/super_admin/models/admin_masjid_request_model.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/masjid_requests/widgets/admin_masjid_request_card.dart';
import 'package:platform_core_frontend/features/super_admin/presentation/masjid_requests/widgets/approve_reject_request_dialog.dart';
import 'package:platform_core_frontend/shared/widgets/error_view.dart';
import 'package:platform_core_frontend/shared/widgets/loading_view.dart';

class AdminMasjidRequestsScreen extends StatefulWidget {
  const AdminMasjidRequestsScreen({super.key, this.repository});

  final SuperAdminRepository? repository;

  @override
  State<AdminMasjidRequestsScreen> createState() =>
      _AdminMasjidRequestsScreenState();
}

class _AdminMasjidRequestsScreenState
    extends State<AdminMasjidRequestsScreen> {
  static const int _pageLimit = 20;

  late final SuperAdminRepository _repository =
      widget.repository ?? SuperAdminRepository();
  final TextEditingController _searchController = TextEditingController();

  List<AdminMasjidRequestModel> _items = <AdminMasjidRequestModel>[];
  String? _selectedStatus;
  String _search = '';
  int _page = 1;
  int _requestRevision = 0;
  Timer? _searchDebounce;
  Future<void>? _activeLoad;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool force = false}) {
    final activeLoad = _activeLoad;
    if (activeLoad != null && !force) return activeLoad;

    final revision = ++_requestRevision;
    _activeLoad = _performLoad(revision).whenComplete(() {
      _activeLoad = null;
    });
    return _activeLoad!;
  }

  Future<void> _performLoad(int revision) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final page = await _repository.getMasjidRequests(
        search: _search,
        status: _selectedStatus,
        page: _page,
        limit: _pageLimit,
      );
      if (!mounted || revision != _requestRevision) return;
      setState(() => _items = page.items);
    } catch (error) {
      if (!mounted || revision != _requestRevision) return;
      setState(() => _errorMessage = _cleanError(error));
    } finally {
      if (mounted && revision == _requestRevision) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onStatusChanged(String? status) {
    if (_selectedStatus == status) return;
    setState(() {
      _selectedStatus = status;
      _page = 1;
    });
    _loadData(force: true);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      final trimmed = value.trim();
      if (_search == trimmed) return;
      setState(() {
        _search = trimmed;
        _page = 1;
      });
      _loadData(force: true);
    });
  }

  Future<void> _approve(AdminMasjidRequestModel item) async {
    final updated = await _repository.updateMasjidRequestStatus(
      item.id,
      'APPROVED',
    );
    if (!mounted) return;
    _replaceItem(updated);
  }

  Future<void> _reject(AdminMasjidRequestModel item) async {
    final reason = await showRejectReasonDialog(context);
    if (reason == null) return;
    final updated = await _repository.updateMasjidRequestStatus(
      item.id,
      'REJECTED',
      reason: reason,
    );
    if (!mounted) return;
    _replaceItem(updated);
  }

  void _replaceItem(AdminMasjidRequestModel updated) {
    setState(() {
      _items = _items
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
    });
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search requests',
              hintText: 'Search by masjid, locality, district, state, or phone',
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _statusChip('All', null),
            _statusChip('Pending', 'PENDING'),
            _statusChip('Approved', 'APPROVED'),
            _statusChip('Rejected', 'REJECTED'),
          ],
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _statusChip(String label, String? status) {
    return FilterChip(
      label: Text(label),
      selected: _selectedStatus == status,
      onSelected: (_) => _onStatusChanged(status),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingView();
    if (_errorMessage != null) {
      return ErrorView(
        title: 'Unable to load',
        message: _errorMessage!,
        onRetry: () => _loadData(force: true),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(force: true),
      child: ListView(
        children: <Widget>[
          for (final item in _items)
            AdminMasjidRequestCard(
              item: item,
              onApprove: () => _approve(item),
              onReject: () => _reject(item),
            ),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No requests found')),
            ),
        ],
      ),
    );
  }
}
