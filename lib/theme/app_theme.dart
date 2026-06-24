import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EdithColors {
  static const bg = Color(0xFF080808);
  static const surface = Color(0xFF111111);
  static const card = Color(0xFF161616);
  static const border = Color(0xFF222222);
  static const borderLight = Color(0xFF2A2A2A);
  static const accent = Color(0xFF2ECC71);
  static const accentDim = Color(0xFF1A7A43);
  static const danger = Color(0xFFE74C3C);
  static const dangerDim = Color(0xFF7A1E16);
  static const textPrimary = Color(0xFFEEEEEE);
  static const textSecondary = Color(0xFF888888);
  static const textDim = Color(0xFF444444);
  static const white = Color(0xFFFFFFFF);
  static const terminalGreen = Color(0xFF39FF14);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: EdithColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: EdithColors.accent,
        secondary: EdithColors.accent,
        surface: EdithColors.surface,
        error: EdithColors.danger,
      ),
      textTheme: GoogleFonts.spaceMonoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: EdithColors.textPrimary, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
          displayMedium: TextStyle(color: EdithColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 6),
          titleLarge: TextStyle(color: EdithColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
          titleMedium: TextStyle(color: EdithColors.textPrimary, fontSize: 14, letterSpacing: 1),
          bodyLarge: TextStyle(color: EdithColors.textPrimary, fontSize: 14),
          bodyMedium: TextStyle(color: EdithColors.textSecondary, fontSize: 12),
          labelSmall: TextStyle(color: EdithColors.textDim, fontSize: 10, letterSpacing: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: EdithColors.bg,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: EdithColors.textPrimary),
        titleTextStyle: TextStyle(
          color: EdithColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
          fontFamily: 'SpaceMono',
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: EdithColors.border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EdithColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: EdithColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: EdithColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: EdithColors.accent),
        ),
        hintStyle: const TextStyle(color: EdithColors.textDim, fontFamily: 'SpaceMono', fontSize: 13),
        labelStyle: const TextStyle(color: EdithColors.textSecondary, fontFamily: 'SpaceMono'),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EdithColors.accent,
          foregroundColor: EdithColors.bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(fontFamily: 'SpaceMono', fontWeight: FontWeight.bold, letterSpacing: 1),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? EdithColors.accent : EdithColors.textDim),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? EdithColors.accentDim : EdithColors.border),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: EdithColors.surface,
        selectedItemColor: EdithColors.accent,
        unselectedItemColor: EdithColors.textDim,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, letterSpacing: 1),
        unselectedLabelStyle: TextStyle(fontFamily: 'SpaceMono', fontSize: 10, letterSpacing: 1),
      ),
    );
  }
}
