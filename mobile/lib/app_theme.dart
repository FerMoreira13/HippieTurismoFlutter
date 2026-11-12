import 'package:flutter/material.dart';

abstract final class AppColors {
  // Paleta de viagem: verde-petróleo, coral e areia.
  static const primary = Color(0xff146c70);
  static const primaryDark = Color(0xff103f43);
  static const primaryLight = Color(0xff23858a);
  static const primarySoft = Color(0xffe2f1ed);
  static const secondary = Color(0xfff4b49d);
  static const secondaryDark = Color(0xff954a35);
  static const secondarySoft = Color(0xfffcebe3);
  // Tom mais escuro do coral para ícones e textos sobre fundos claros.
  static const accent = Color(0xffad4d36);
  static const accentDark = Color(0xff803824);
  static const accentSoft = Color(0xfffcebe3);
  static const background = Color(0xfffaf7ef);
  static const ink = Color(0xff243b3b);
  static const muted = Color(0xff586c69);
  static const line = Color(0xffdde3d9);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    tertiary: AppColors.secondary,
    onTertiary: AppColors.primaryDark,
    surface: AppColors.background,
    onSurface: AppColors.ink,
    surfaceContainerHighest: AppColors.secondarySoft,
    outline: AppColors.line,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: base.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontSize: 42,
        height: .98,
        fontWeight: FontWeight.w800,
        letterSpacing: -2.1,
        color: AppColors.ink,
      ),
      headlineLarge: const TextStyle(
        fontSize: 32,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.25,
        color: AppColors.ink,
      ),
      headlineMedium: const TextStyle(
        fontSize: 25,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: -.7,
        color: AppColors.ink,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        height: 1.55,
        color: AppColors.ink,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.45,
        color: AppColors.muted,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: .1,
      ),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 50),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      labelStyle: const TextStyle(color: AppColors.muted),
      hintStyle: const TextStyle(color: AppColors.muted),
      prefixIconColor: AppColors.primary,
      suffixIconColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.7),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: scheme.error),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 74,
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.secondarySoft,
      shadowColor: Colors.black12,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryDark
              : AppColors.muted,
          fontSize: 11.5,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w600,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.muted,
          size: 23,
        ),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: Colors.white,
      selectedColor: AppColors.secondarySoft,
      side: const BorderSide(color: AppColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primaryDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.accentSoft,
    ),
  );
}
