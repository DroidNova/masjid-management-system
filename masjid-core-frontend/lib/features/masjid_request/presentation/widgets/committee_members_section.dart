import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/features/masjid_request/application/masjid_request_validators.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/masjid_request_form_fields.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/form_section.dart';
import 'package:masjid_core_frontend/features/masjid_request/presentation/widgets/person_fields.dart';
import 'package:masjid_core_frontend/shared/widgets/app_button.dart';
import 'package:masjid_core_frontend/shared/widgets/app_phone_field.dart';
import 'package:masjid_core_frontend/shared/widgets/app_text_field.dart';

/// The list of committee members with add / remove.
class CommitteeMembersSection extends StatelessWidget {
  const CommitteeMembersSection({
    super.key,
    required this.members,
    required this.onAdd,
    required this.onRemove,
  });

  final List<CommitteeMemberFields> members;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormSection(
      title: 'Committee Members',
      children: <Widget>[
        if (members.isEmpty)
          Text(
            'No committee members added yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        for (var index = 0; index < members.length; index++)
          CommitteeMemberFieldsView(
            // Keeps each member's field state when one above is removed.
            key: ObjectKey(members[index]),
            member: members[index],
            index: index,
            onRemove: () => onRemove(index),
          ),
        AppButton(
          label: '+ Add Committee Member',
          isOutlined: true,
          onPressed: onAdd,
        ),
      ],
    );
  }
}

class CommitteeMemberFieldsView extends StatelessWidget {
  const CommitteeMemberFieldsView({
    super.key,
    required this.member,
    required this.index,
    required this.onRemove,
  });

  final CommitteeMemberFields member;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Member ${index + 1}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('Remove'),
            ),
          ],
        ),
        AppTextField(
          controller: member.name,
          label: 'Committee Member Name *',
          textInputAction: TextInputAction.next,
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Committee member name is required.'
              : null,
        ),
        const SizedBox(height: 14),
        AppPhoneField(
          phoneController: member.phone,
          initialCountry: member.country,
          onCountryChanged: (country) => member.country = country,
          label: 'Committee Member Mobile Number *',
          isRequired: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: member.fatherName,
          label: 'Father Name *',
          textInputAction: TextInputAction.next,
          validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Father name is required.'
              : null,
        ),
        const SizedBox(height: 14),
        AgeField(
          controller: member.age,
          label: 'Age *',
          validator: (value) => MasjidRequestValidators.age(value, 'Age'),
        ),
        const SizedBox(height: 14),
        GenderField(
          value: member.gender,
          label: 'Gender *',
          requiredMessage: 'Gender is required.',
          onChanged: (value) => member.gender = value,
        ),
        const Divider(height: 28),
      ],
    );
  }
}
