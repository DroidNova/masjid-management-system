import 'package:flutter/material.dart';
import 'package:platform_core_frontend/core/errors/error_message_helper.dart';
import 'package:platform_core_frontend/core/permissions/permission_helper.dart';
import 'package:platform_core_frontend/core/storage/session_storage.dart';
import 'package:platform_core_frontend/features/community/data/community_repository.dart';
import 'package:platform_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:platform_core_frontend/features/contributions/data/contributions_repository.dart';
import 'package:platform_core_frontend/features/contributions/models/collection_contribution_model.dart';
import 'package:platform_core_frontend/features/contributions/presentation/widgets/contribution_transaction_card.dart';
import 'package:platform_core_frontend/shared/utils/paginated_list_controller.dart';
import 'package:platform_core_frontend/shared/widgets/app_date_field.dart';
import 'package:platform_core_frontend/shared/widgets/app_phone_field.dart';

const List<String> _collectionTypes = <String>[
  'JUMMA_COLLECTION',
  'DONATION_BOX',
  'RAMADAN_FUND',
  'ZAKAT',
  'SADAQAH',
  'CONSTRUCTION_FUND',
  'OTHER',
];

String _collectionTypeLabel(String value) {
  return value
      .split('_')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0]}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

class CollectionContributionsScreen extends StatefulWidget {
  const CollectionContributionsScreen({super.key});

  @override
  State<CollectionContributionsScreen> createState() =>
      _CollectionContributionsScreenState();
}

class _CollectionContributionsScreenState
    extends State<CollectionContributionsScreen> {
  final ContributionsRepository _repository = ContributionsRepository();
  final ScrollController _scrollController = ScrollController();
  late final PaginatedListController<CollectionContributionModel>
      _contributions;

  bool _canAdd = false;
  String? _paymentMode;
  String? _collectionType;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _contributions = PaginatedListController<CollectionContributionModel>(
      loader: (page, limit) => _repository.getCollectionContributions(
        page: page,
        limit: limit,
        search: _search,
        paymentMode: _paymentMode,
        collectionType: _collectionType,
      ),
      errorMapper: getReadableErrorMessage,
    )..addListener(_onContributionsChanged);
    _scrollController.addListener(_loadMoreNearBottom);
    _loadPermissions();
    _contributions.refresh();
  }

  @override
  void dispose() {
    _contributions.removeListener(_onContributionsChanged);
    _contributions.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPermissions() async {
    final user = await SessionStorage().getUser();
    if (!mounted) return;
    setState(() {
      _canAdd = PermissionHelper.canManageFinance(
        user?.roles ?? const <String>[],
      );
    });
  }

  void _onContributionsChanged() {
    if (mounted) setState(() {});
  }

  void _loadMoreNearBottom() {
    if (_scrollController.position.extentAfter < 300) {
      _contributions.loadNext();
    }
  }

  Future<void> _openAddContribution() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _CollectionContributionDialog(
        repository: _repository,
      ),
    );
    if (saved == true) await _contributions.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Collection Contributions')),
      floatingActionButton: _canAdd
          ? FloatingActionButton.extended(
              onPressed: _openAddContribution,
              icon: const Icon(Icons.add),
              label: const Text('Add Contribution'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _contributions.refresh,
        child: ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search name or phone',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                _search = value.trim();
                _contributions.refresh();
              },
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _collectionType,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All types'),
                      ),
                      ..._collectionTypes.map(
                        (type) => DropdownMenuItem<String?>(
                          value: type,
                          child: Text(_collectionTypeLabel(type)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      _collectionType = value;
                      _contributions.refresh();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: _paymentMode,
                    decoration: const InputDecoration(labelText: 'Mode'),
                    items: const <DropdownMenuItem<String?>>[
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'CASH',
                        child: Text('Cash'),
                      ),
                      DropdownMenuItem<String?>(
                        value: 'ONLINE',
                        child: Text('Online'),
                      ),
                    ],
                    onChanged: (value) {
                      _paymentMode = value;
                      _contributions.refresh();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_contributions.items.isEmpty && !_contributions.isLoading)
              const Center(child: Text('No collection contributions yet.')),
            ..._contributions.items.map(
              (contribution) => ContributionTransactionCard(
                title: contribution.contributorName,
                subtitle: _collectionTypeLabel(contribution.collectionType),
                amount: contribution.amount,
                paymentMode: contribution.paymentMode,
                paidAt: contribution.paidAt,
                collectedByName: contribution.collectedByName,
                note: contribution.note,
              ),
            ),
            if (_contributions.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_contributions.error != null)
              Text(_contributions.error!, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _CollectionContributionDialog extends StatefulWidget {
  const _CollectionContributionDialog({required this.repository});

  final ContributionsRepository repository;

  @override
  State<_CollectionContributionDialog> createState() =>
      _CollectionContributionDialogState();
}

class _CollectionContributionDialogState
    extends State<_CollectionContributionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<CommunityUserModel> _members = <CommunityUserModel>[];
  String? _memberId;
  String _collectionType = 'DONATION_BOX';
  String _paymentMode = 'CASH';
  String _normalizedPhone = '';
  DateTime _paidAt = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await CommunityRepository().getMyMasjidUsers();
      if (mounted) setState(() => _members = members);
    } catch (_) {
      // External contributor entry remains available if members cannot load.
    }
  }

  void _selectMember(String? memberId) {
    final matches = _members.where((member) => member.id == memberId);
    setState(() {
      _memberId = memberId;
      if (matches.isNotEmpty) {
        final member = matches.first;
        _nameController.text = member.fullName;
        _phoneController.text = member.phone ?? '';
        _normalizedPhone = member.phone ?? '';
      }
    });
  }

  String? _validateName(String? value) {
    return value == null || value.trim().isEmpty ? 'Name is required' : null;
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value ?? '');
    return amount == null || amount <= 0 ? 'Enter a valid amount' : null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Collection Contribution'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String?>(
                  initialValue: _memberId,
                  decoration: const InputDecoration(
                    labelText: 'Member (optional)',
                  ),
                  items: <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('External contributor'),
                    ),
                    ..._members.map(
                      (member) => DropdownMenuItem<String?>(
                        value: member.id,
                        child: Text(member.fullName),
                      ),
                    ),
                  ],
                  onChanged: _selectMember,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Contributor name *',
                  ),
                  validator: _validateName,
                ),
                AppPhoneField(
                  phoneController: _phoneController,
                  label: 'Contributor phone',
                  onNormalizedPhoneChanged: (value) {
                    _normalizedPhone = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  initialValue: _collectionType,
                  decoration: const InputDecoration(
                    labelText: 'Collection type *',
                  ),
                  items: _collectionTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(_collectionTypeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _collectionType = value;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount *'),
                  validator: _validateAmount,
                ),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMode,
                  decoration: const InputDecoration(
                    labelText: 'Payment mode *',
                  ),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: 'CASH',
                      child: Text('Cash'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'ONLINE',
                      child: Text('Online'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) _paymentMode = value;
                  },
                ),
                const SizedBox(height: 12),
                AppDateField(
                  label: 'Paid date',
                  selectedDate: _paidAt,
                  onDateSelected: (value) {
                    if (value != null) _paidAt = value;
                  },
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  required: true,
                ),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Note (optional)',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.repository.addCollectionContribution(
        CreateCollectionContributionRequest(
          memberId: _memberId,
          contributorName: _nameController.text,
          contributorPhone: _normalizedPhone,
          collectionType: _collectionType,
          amount: double.parse(_amountController.text),
          paymentMode: _paymentMode,
          paidAt: _paidAt,
          note: _noteController.text,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(getReadableErrorMessage(error))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
