import 'package:flutter/material.dart';

/// Design tokens: the only place colours, spacing, sizes, and timings are
/// defined. Screens use these (or the theme built from them), never raw
/// values, so the whole app keeps one look.

/// A colour pair for one meaning: [color] for icons, text, and solid fills
/// (readable on white and with white on top), [container] for light
/// backgrounds behind it.
@immutable
class AppTone {
  const AppTone(this.color, this.container);

  final Color color;
  final Color container;
}

/// Same meaning, same colour, everywhere (UI_REDESIGN_PLAN.md, rule 3).
/// Every [AppTone.color] has at least 4.5:1 contrast on white and on its
/// own container.
class AppTones {
  const AppTones._();

  static const AppTone brand = AppTone(Color(0xFF00695C), Color(0xFFDDF2EF));
  static const AppTone namaz = AppTone(Color(0xFF1D4E9E), Color(0xFFE3ECFA));
  static const AppTone news = AppTone(Color(0xFF8A5300), Color(0xFFFFF0D4));
  static const AppTone moneyIn = AppTone(Color(0xFF13773B), Color(0xFFE2F4E8));
  static const AppTone moneyOut = AppTone(Color(0xFFB3261E), Color(0xFFFCE8E6));
  static const AppTone projects = AppTone(Color(0xFF6A3FB5), Color(0xFFEFE8FA));
  static const AppTone people = AppTone(Color(0xFF006A73), Color(0xFFDDF1F3));
  static const AppTone salary = AppTone(Color(0xFF7A4A1E), Color(0xFFF4EADF));
  static const AppTone neutral = AppTone(Color(0xFF4A5560), Color(0xFFEEF1F3));

  /// Status colours reuse the money colours: done is green, waiting is
  /// amber, a problem is red.
  static const AppTone done = moneyIn;
  static const AppTone waiting = news;
  static const AppTone problem = moneyOut;
  static const AppTone danger = moneyOut;

  /// Avatar backgrounds, picked by name so a person always gets the same one.
  static const List<AppTone> avatar = <AppTone>[
    brand,
    namaz,
    news,
    projects,
    people,
    salary,
  ];
}

class AppColors {
  const AppColors._();

  /// Page background: a soft off-white so white cards stand out.
  static const Color background = Color(0xFFF5F7F6);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFDDE3E1);
  static const Color textPrimary = Color(0xFF17201E);
  static const Color textSecondary = Color(0xFF55615E);
}

/// Spacing scale (dp).
class AppSpace {
  const AppSpace._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadius {
  const AppRadius._();

  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 28;
}

class AppSizes {
  const AppSizes._();

  /// Smallest tappable size (rule 5).
  static const double minTouch = 56;

  /// Widest a page's content grows on big screens.
  static const double maxContentWidth = 1100;

  /// Forms and dialogs stay narrow so lines are easy to follow.
  static const double maxFormWidth = 560;
}

class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);

  /// How long a dangerous action's button must be held.
  static const Duration holdToConfirm = Duration(seconds: 2);
}
