/// A rule across the committee members that failed.
enum CommitteeProblem {
  /// No committee member at all.
  missing,

  /// A committee member has the imam's phone number.
  imamIsMember,

  /// Two committee members share a phone number.
  duplicatePhone,
}

/// Validation for the public masjid registration form. Pure functions, so the
/// rules can be unit tested without widgets. Messages are passed in, so the
/// screen shows them in the app's language.
class MasjidRequestValidators {
  const MasjidRequestValidators._();

  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// [message] when empty or blank.
  static String? required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  /// Optional email: empty is fine, otherwise [message] unless it looks
  /// like an email address.
  static String? email(String? value, String message) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!_emailPattern.hasMatch(trimmed)) return message;
    return null;
  }

  /// Required whole number from 1 to 120.
  static String? age(
    String? value, {
    required String requiredMessage,
    required String rangeMessage,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return requiredMessage;
    final age = int.tryParse(text);
    if (age == null || age < 1 || age > 120) return rangeMessage;
    return null;
  }

  /// Rules across fields: at least one committee member, the imam is not on
  /// the committee, no repeated phone. Phones are normalized (`+91...`).
  static CommitteeProblem? committeePhones({
    required String imamPhone,
    required List<String> committeePhones,
  }) {
    if (committeePhones.isEmpty) return CommitteeProblem.missing;
    final seen = <String>{};
    for (final phone in committeePhones) {
      if (phone == imamPhone) return CommitteeProblem.imamIsMember;
      if (!seen.add(phone)) return CommitteeProblem.duplicatePhone;
    }
    return null;
  }
}
