import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NothingTheme {
  // Pure Black & White with Nothing Red Accent
  static const Color black = Color(0xFF000000);
  static const Color surface = Color(0xFF111111);
  static const Color surfaceElevated = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF242424);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF8A8A8E);
  static const Color darkGrey = Color(0xFF333333);
  static const Color border = Color(0x33FFFFFF); // 20% white
  static const Color borderFocused = Color(0x77FFFFFF); // 47% white
  static const Color red = Color(0xFFD71921); // Iconic Nothing Red

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      canvasColor: black,
      colorScheme: const ColorScheme.dark(
        primary: white,
        onPrimary: black,
        surface: surface,
        onSurface: white,
        secondary: grey,
        onSecondary: black,
        error: red,
        onError: white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: black,
        foregroundColor: white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.spaceMono(
          color: white,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: white),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceMono(
          color: white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        displayMedium: GoogleFonts.spaceMono(
          color: white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
        titleLarge: GoogleFonts.spaceMono(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
        titleMedium: GoogleFonts.spaceMono(
          color: white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
        ),
        bodyLarge: GoogleFonts.inter(
          color: white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: const Color(0xFFD1D1D6),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.inter(
          color: grey,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.spaceMono(
          color: white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
        labelSmall: GoogleFonts.spaceMono(
          color: grey,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevated,
        contentTextStyle: GoogleFonts.spaceMono(color: white, fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
