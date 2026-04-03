import 'package:flutter/material.dart';

/// Canonical app theme.
///
/// Use [AppTheme] in new code. The [Default_Theme] typedef at the bottom of
/// this file provides backward-compatible access for existing callers while
/// imports are being migrated.
class AppTheme {
  // ── Text Styles ─────────────────────────────────────────────────────────────
  static const primaryTextStyle = TextStyle(fontFamily: "Fjalla");
  static const secondoryTextStyle = TextStyle(fontFamily: "Gilroy");
  static const secondoryTextStyleMedium =
      TextStyle(fontFamily: "Gilroy", fontWeight: FontWeight.w700);
  static const tertiaryTextStyle = TextStyle(fontFamily: "CodePro");
  static const fontAwesomeRegularFont =
      TextStyle(fontFamily: "FontAwesome-Regular");
  static const fontAwesomeSolidFont =
      TextStyle(fontFamily: "FontAwesome-Solids");

  // ── Colors ──────────────────────────────────────────────────────────────────
  static const themeColor = Color(0xFF070707); // Neutral Deep Black
  static const primaryColor1 = Color(0xFFDAEAF7);
  static const primaryColor2 = Color.fromARGB(255, 242, 231, 240);
  static const accentColor1 = Color(0xFF0EA5E0);
  static const accentColor1light = Color(0xFF18C9ED);
  static const accentColor2 = Color(0xFF1DB954); // Changed from Red to Match Success Green
  static const successColor = Color(0xFF5EFF43);
  static const successAccent = Color(0xFF1DB954); // Spotify-like green

  // ── Theme Data ───────────────────────────────────────────────────────────────
  ThemeData get defaultThemeData {
    const darkScheme = ColorScheme.dark(
      primary: successAccent,
      secondary: accentColor1,
      surface: themeColor,
      surfaceContainerHighest: Color(0xFF1A111B),
      onPrimary: primaryColor1,
      onSecondary: primaryColor1,
      onSurface: primaryColor1,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: themeColor,
      primaryColorDark: successAccent,
      fontFamily: 'Gilroy',
      primarySwatch: MaterialColor(
        successAccent.value,
        {
          50: successAccent.withValues(alpha: 0.1),
          100: successAccent.withValues(alpha: 0.2),
          200: successAccent.withValues(alpha: 0.3),
          300: successAccent.withValues(alpha: 0.4),
          400: successAccent.withValues(alpha: 0.5),
          500: successAccent.withValues(alpha: 0.6),
          600: successAccent.withValues(alpha: 0.7),
          700: successAccent.withValues(alpha: 0.8),
          800: successAccent.withValues(alpha: 0.9),
          900: successAccent,
        },
      ),
      colorScheme: darkScheme.copyWith(
        primary: successAccent,
        secondary: successAccent,
      ),
      iconTheme: const IconThemeData(color: primaryColor1),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(successAccent),
        interactive: true,
        radius: const Radius.circular(10),
        thickness: WidgetStateProperty.all(5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: themeColor,
        foregroundColor: primaryColor1,
        surfaceTintColor: themeColor,
        iconTheme: IconThemeData(color: primaryColor1),
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: successAccent),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: successAccent,
        selectionColor: successAccent,
        selectionHandleColor: successAccent,
      ),
      brightness: Brightness.dark,
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(primaryColor1),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? successAccent
                : successAccent.withValues(alpha: 0.5)),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? successAccent
                : Colors.transparent),
      ),
      searchBarTheme: const SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(themeColor),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        color: Color.fromARGB(255, 23, 18, 25),
        textStyle: TextStyle(color: primaryColor1),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(themeColor),
        ),
        textStyle: TextStyle(color: primaryColor1),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(themeColor),
        ),
      ),
      cardTheme: const CardThemeData(
        color: themeColor,
        surfaceTintColor: Colors.transparent,
      ), dialogTheme: const DialogThemeData(backgroundColor: themeColor),
    );
  }
}

/// Backward-compat alias for [AppTheme].
/// Prefer importing from [core/theme/app_theme.dart] and using [AppTheme] directly.
// ignore: camel_case_types
typedef Default_Theme = AppTheme;
