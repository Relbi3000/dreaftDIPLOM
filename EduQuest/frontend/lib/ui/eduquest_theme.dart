import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EduQuestColors {
  static const bg = Color(0xFF07131F);
  static const bgElevated = Color(0xFF102235);
  static const surface = Color(0xFF13283E);
  static const surfaceAlt = Color(0xFF1A3551);
  static const primary = Color(0xFF26B3A8);
  static const primarySoft = Color(0xFF153F47);
  static const secondary = Color(0xFFF3B14A);
  static const accent = Color(0xFFFC7A57);
  static const success = Color(0xFF5AD08C);
  static const danger = Color(0xFFF06B78);
  static const info = Color(0xFF66B9FF);
  static const border = Color(0xFF29405A);
  static const textMuted = Color(0xFF96A8BE);
}

ThemeData buildEduQuestTheme() {
  final baseText = GoogleFonts.manropeTextTheme();
  final darkScheme = ColorScheme.dark(
    primary: EduQuestColors.primary,
    secondary: EduQuestColors.secondary,
    surface: EduQuestColors.surface,
    error: EduQuestColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: darkScheme,
    scaffoldBackgroundColor: EduQuestColors.bg,
    canvasColor: EduQuestColors.bgElevated,
    textTheme: baseText.copyWith(
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      titleMedium: baseText.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: baseText.bodyLarge?.copyWith(
        color: Colors.white,
        height: 1.45,
      ),
      bodyMedium: baseText.bodyMedium?.copyWith(
        color: Colors.white,
        height: 1.45,
      ),
      bodySmall: baseText.bodySmall?.copyWith(
        color: EduQuestColors.textMuted,
        height: 1.35,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: EduQuestColors.bg,
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: EduQuestColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: EduQuestColors.border),
      ),
    ),
    dividerColor: EduQuestColors.border,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: EduQuestColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: EduQuestColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: EduQuestColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: EduQuestColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: EduQuestColors.danger),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      labelStyle: const TextStyle(color: EduQuestColors.textMuted),
      hintStyle: const TextStyle(color: EduQuestColors.textMuted),
      prefixIconColor: EduQuestColors.textMuted,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: EduQuestColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: EduQuestColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: EduQuestColors.bgElevated,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: EduQuestColors.bgElevated,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 12,
          fontWeight:
              states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
          color:
              states.contains(WidgetState.selected)
                  ? Colors.white
                  : EduQuestColors.textMuted,
        );
      }),
      indicatorColor: EduQuestColors.primarySoft,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color:
              states.contains(WidgetState.selected)
                  ? EduQuestColors.primary
                  : EduQuestColors.textMuted,
        );
      }),
    ),
  );
}
