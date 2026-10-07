/// Validation for the public masjid registration form. Pure functions, so the
/// rules can be unit tested without widgets. Messages match the old screen.
class MasjidRequestValidators {
  const MasjidRequestValidators._();

  static const String committeeRequired =
      'At least one committee member is required.';
  static const String imamIsCommitteeMember =
      'Imam cannot also be a committee member.';
  static const String duplicateCommitteePhone =
      'Committee member mobile number is duplicated.';

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// "<label> is required." when empty.
  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  /// Optional email: empty is fine, otherwise "Enter a valid <label>.".
  static String? email(String? value, String label) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!_emailPattern.hasMatch(trimmed)) return 'Enter a valid $label.';
    return null;
  }

  /// Required whole number from 1 to 120.
  static String? age(String? value, String label) {
    final age = int.tryParse(value?.trim() ?? '');
    if (age == null) return '$label is required.';
    if (age < 1 || age > 120) return '$label must be between 1 and 120.';
    return null;
  }

  /// Rules across fields, checked after the form validates: at least one
  /// committee member, the imam is not on the committee, no repeated phone.
  /// Phones are normalized (`+91...`). Returns the message to show, or null.
  static String? committeePhones({
    required String imamPhone,
    required List<String> committeePhones,
  }) {
    if (committeePhones.isEmpty) return committeeRequired;
    final seen = <String>{};
    for (final phone in committeePhones) {
      if (phone == imamPhone) return imamIsCommitteeMember;
      if (!seen.add(phone)) return duplicateCommitteePhone;
    }
    return null;
  }
}
