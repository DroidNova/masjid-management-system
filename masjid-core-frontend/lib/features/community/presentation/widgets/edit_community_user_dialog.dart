import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:masjid_core_frontend/features/community/data/models/community_user_model.dart';
import 'package:masjid_core_frontend/features/community/data/models/update_community_user_request.dart';
import 'package:masjid_core_frontend/features/community/presentation/widgets/gender_dropdown.dart';

/// Edits a user's profile; pops an [UpdateCommunityUserRequest] on save.
class EditCommunityUserDialog extends StatefulWidget {
  const EditCommunityUserDialog({super.key, required this.user});

  final CommunityUserModel user;

  @override
  State<EditCommunityUserDialog> createState() =>
      _EditCommunityUserDialogState();
}

class _EditCommunityUserDialogState extends State<EditCommunityUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(
    text: widget.user.fullName,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.user.phone ?? '',
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.user.email ?? '',
  );
  late final TextEditingController _fatherName = TextEditingController(
    text: widget.user.fatherName ?? '',
  );
  late final TextEditingController _age = TextEditingController(
    text: widget.user.age?.toString() ?? '',
  );
  late final TextEditingController _familyMemberCount = TextEditingController(
    text: widget.user.familyMemberCount?.toString() ?? '',
  );
  late String? _gender = widget.user.gender;
  late bool _isFamilyHead = widget.user.isFamilyHead;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _fatherName.dispose();
    _age.dispose();
    _familyMemberCount.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final email = _email.text.trim();
    final count = _familyMemberCount.text.trim();
    Navigator.of(context).pop(
      UpdateCommunityUserRequest(
        fullName: _name.text.trim(),
        phone: _phone.text.trim(),
        email: email.isEmpty ? null : email,
        fatherName: _fatherName.text.trim(),
        age: int.parse(_age.text.trim()),
        gender: _gender!,
        isFamilyHead: widget.user.isMember ? _isFamilyHead : null,
        familyMemberCount: count.isEmpty ? null : int.parse(count),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit user'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Full name *'),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Full name is required' : null,
            ),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(labelText: 'Phone *'),
              validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Phone is required' : null,
            ),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _fatherName,
              decoration: const InputDecoration(labelText: 'Father name *'),
              validator: (v) => (v?.trim().isEmpty ?? true)
                  ? 'Father name is required'
                  : null,
            ),
            TextFormField(
              controller: _age,
              decoration: const InputDecoration(labelText: 'Age *'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (v) {
                final age = int.tryParse(v?.trim() ?? '');
                if (age == null) return 'Age is required';
                if (age < 1 || age > 120) {
                  return 'Age must be between 1 and 120';
                }
                return null;
              },
            ),
            GenderDropdown(
              value: _gender,
              outlined: false,
              requiredMessage: 'Gender is required',
              onChanged: (value) => setState(() => _gender = value),
            ),
            if (widget.user.isMember)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Is Family Head *'),
                value: _isFamilyHead,
                onChanged: (value) => setState(() => _isFamilyHead = value),
              ),
            if (widget.user.isMember && _isFamilyHead)
              TextFormField(
                controller: _familyMemberCount,
                decoration: const InputDecoration(
                  labelText: 'Family Member Count',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
