import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masjid_core_frontend/core/errors/user_message.dart';
import 'package:masjid_core_frontend/features/contributions/application/contribution_list_controllers.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/contributor_option.dart';
import 'package:masjid_core_frontend/features/contributions/data/models/new_contribution.dart';
import 'package:masjid_core_frontend/shared/widgets/app_date_field.dart';
import 'package:masjid_core_frontend/shared/widgets/app_phone_field.dart';

const List<String> collectionTypes = <String>[
  'JUMMA_COLLECTION',
  'DONATION_BOX',
  'RAMADAN_FUND',
  'ZAKAT',
  'SADAQAH',
  'CONSTRUCTION_FUND',
  'OTHER',
];

/// "DONATION_BOX" -> "Donation Box".
String collectionTypeLabel(String value) => value
    .split('_')
    .map(
      (word) =>
          word.isEmpty ? word : '${word[0]}${word.substring(1).toLowerCase()}',
    )
    .join(' ');

/// Validates a contribution amount typed by the user.
String? validateContributionAmount(String? value) {
  final amount = double.tryParse(value?.trim() ?? '');
  return amount == null || amount <= 0 ? 'Enter a valid amount' : null;
}

/// Records a project contribution (when [projectId] is set) or a general
/// collection contribution. Pops `true` after saving.
class ContributionFormDialog extends ConsumerStatefulWidget {
  const ContributionFormDialog.project({
    super.key,
    required String this.projectId,
  });

  const ContributionFormDialog.collection({super.key}) : projectId = null;

  final String? projectId;

  bool get isCollection => projectId == null;

  @override
  ConsumerState<ContributionFormDialog> createState() =>
      _ContributionFormDialogState();
}

class _ContributionFormDialogState
    extends ConsumerState<ContributionFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _memberId;
  String _collectionType = 'DONATION_BOX';
  String _paymentMode = 'CASH';
  String _normalizedPhone = '';
  DateTime _paidAt = DateTime.now();
  bool _saving = false;
  Object? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _selectMember(List<ContributorOption> members, String? memberId) {
    final matches = members.where((member) => member.id == memberId);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _error = null;
    });
    final contribution = NewContribution(
      memberId: _memberId,
      contributorName: _nameController.text,
      contributorPhone: _normalizedPhone,
      amount: double.parse(_amountController.text.trim()),
      paymentMode: _paymentMode,
      paidAt: _paidAt,
      note: _noteController.text,
      collectionType: widget.isCollection ? _collectionType : null,
    );
    final recorder = ref.read(contributionRecorderProvider);
    try {
      if (widget.isCollection) {
        await recorder.recordCollectionContribution(contribution);
      } else {
        await recorder.recordProjectContribution(
          widget.projectId!,
          contribution,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(userMessage(error))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(contributorOptionsProvider);
    final members = options.valueOrNull ?? const <ContributorOption>[];
    final optionsError = options.hasError && !options.isLoading
        ? options.error
        : null;

    return AlertDialog(
      title: Text(
        widget.isCollection
            ? 'Add Collection Contribution'
            : 'Add Project Contribution',
      ),
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
                      child: Text('External contributor'),
                    ),
                    ...members.map(
                      (member) => DropdownMenuItem<String?>(
                        value: member.id,
                        child: Text(member.fullName),
                      ),
                    ),
                  ],
                  onChanged: (value) => _selectMember(members, value),
                ),
                if (optionsError != null)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Members could not be loaded: '
                          '${userMessage(optionsError)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            ref.invalidate(contributorOptionsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Contributor name *',
                    errorText: fieldError(_error, 'contributorName'),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                AppPhoneField(
                  phoneController: _phoneController,
                  label: 'Contributor phone',
                  onNormalizedPhoneChanged: (value) {
                    _normalizedPhone = value;
                  },
                ),
                if (widget.isCollection)
                  DropdownButtonFormField<String>(
                    initialValue: _collectionType,
                    decoration: const InputDecoration(
                      labelText: 'Collection type *',
                    ),
                    items: collectionTypes
                        .map(
                          (type) => DropdownMenuItem<String>(
                            value: type,
                            child: Text(collectionTypeLabel(type)),
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
                  decoration: InputDecoration(
                    labelText: 'Amount *',
                    errorText: fieldError(_error, 'amount'),
                  ),
                  validator: validateContributionAmount,
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
                  decoration: InputDecoration(
                    labelText: 'Note (optional)',
                    errorText: fieldError(_error, 'note'),
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
}
