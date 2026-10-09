// Newer Flutter versions move CupertinoPageTransitionsBuilder from material
// to cupertino; importing both builds on either (CI pins 3.41.6, where the
// cupertino import is redundant).
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:masjid_core_frontend/shared/ui/tokens.dart';

/// The app's one theme, built from the design tokens.
class AppTheme {
  const AppTheme._();

  static const String latinFont = 'Mukta';
  static const String urduFont = 'NotoNastaliqUrdu';

  /// [languageCode] picks the font: Mukta covers English and Hindi, Noto
  /// Nastaliq Urdu covers Urdu. Each falls back to the other for mixed text
  /// (an English name inside Urdu text, digits, and so on).
  static ThemeData light({String languageCode = 'en'}) {
    final isUrdu = languageCode == 'ur';
    final fontFamily = isUrdu ? urduFont : latinFont;
    final fallback = <String>[isUrdu ? latinFont : urduFont];

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppTones.brand.color,
      primary: AppTones.brand.color,
      primaryContainer: AppTones.brand.container,
      error: AppTones.danger.color,
      errorContainer: AppTones.danger.container,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outlineVariant: AppColors.border,
    );

    final textTheme = _textTheme(isUrdu: isUrdu).apply(
      fontFamily: fontFamily,
      fontFamilyFallback: fallback,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.m),
    );
    const buttonSize = Size(AppSizes.minTouch, AppSizes.minTouch);
    final buttonText = textTheme.labelLarge;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      fontFamilyFallback: fallback,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          // Android 14+ predictive back; older versions get the default.
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          // Swipe from the edge to go back.
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.l),
          side: const BorderSide(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
          shape: buttonShape,
          textStyle: buttonText,
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: buttonSize),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.l,
          vertical: AppSpace.l,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
          borderSide: BorderSide(color: AppTones.brand.color, width: 2),
        ),
        labelStyle: textTheme.bodyLarge,
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: textTheme.titleSmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.m,
          vertical: AppSpace.s,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        side: const BorderSide(color: AppColors.border),
        selectedColor: AppTones.brand.container,
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppTones.brand.container,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
          textTheme.labelMedium,
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 28,
            color: states.contains(WidgetState.selected)
                ? AppTones.brand.color
                : AppColors.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppTones.brand.container,
        selectedIconTheme: IconThemeData(size: 28, color: AppTones.brand.color),
        unselectedIconTheme: const IconThemeData(
          size: 28,
          color: AppColors.textSecondary,
        ),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: AppTones.brand.color,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: textTheme.bodyLarge?.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        space: 1,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: AppSpace.m,
        minTileHeight: AppSizes.minTouch,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Base text 18 (rule 5). Big numbers use [TextTheme.displayMedium].
  /// Nastaliq is tall, so Urdu gets more line height.
  static TextTheme _textTheme({required bool isUrdu}) {
    final height = isUrdu ? 1.9 : 1.35;
    TextStyle style(double size, FontWeight weight) =>
        TextStyle(fontSize: size, fontWeight: weight, height: height);

    return TextTheme(
      displayLarge: style(56, FontWeight.w700).copyWith(height: 1.1),
      displayMedium: style(44, FontWeight.w700).copyWith(height: 1.1),
      displaySmall: style(36, FontWeight.w700).copyWith(height: 1.15),
      headlineLarge: style(32, FontWeight.w700),
      headlineMedium: style(28, FontWeight.w700),
      headlineSmall: style(24, FontWeight.w700),
      titleLarge: style(22, FontWeight.w700),
      titleMedium: style(19, FontWeight.w600),
      titleSmall: style(17, FontWeight.w600),
      bodyLarge: style(18, FontWeight.w400),
      bodyMedium: style(16, FontWeight.w400),
      bodySmall: style(14, FontWeight.w400),
      labelLarge: style(18, FontWeight.w600),
      labelMedium: style(15, FontWeight.w600),
      labelSmall: style(13, FontWeight.w600),
    );
  }
}
