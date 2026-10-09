import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// A circle with a person's initials. The colour comes from the name, so the
/// same person always looks the same in every list.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.name, this.size = 48});

  final String name;
  final double size;

  /// First letter of the first two words ("Mohammed Rafiq" → "MR").
  /// Works for Hindi and Urdu names too (whole characters, not bytes).
  static String initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .take(2);
    final letters = words.map((word) => word.characters.first).join();
    return letters.isEmpty ? '?' : letters.toUpperCase();
  }

  static AppTone toneFor(String name) {
    final hash = name.trim().toLowerCase().codeUnits.fold<int>(
      0,
      (sum, unit) => (sum * 31 + unit) & 0x7fffffff,
    );
    return AppTones.avatar[hash % AppTones.avatar.length];
  }

  @override
  Widget build(BuildContext context) {
    final tone = toneFor(name);
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tone.container,
          shape: BoxShape.circle,
        ),
        child: Text(
          initials(name),
          style: TextStyle(
            color: tone.color,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
            height: 1,
          ),
        ),
      ),
    );
  }
}
