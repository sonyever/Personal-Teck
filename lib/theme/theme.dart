import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PTColors {
  // Primária — verde floresta
  static const primary900 = Color(0xFF0F2D1F);
  static const primary800 = Color(0xFF1A4A31);
  static const primary600 = Color(0xFF2E7D52);
  static const primary400 = Color(0xFF52A876);
  static const primary200 = Color(0xFF8ECBA8);
  static const primary100 = Color(0xFFBDE0CC);
  static const primary50  = Color(0xFFE6F5EE);

  // Secundária — sage / oliva
  static const teal800 = Color(0xFF3D5A40);
  static const teal600 = Color(0xFF4F7652);
  static const teal400 = Color(0xFF6A9C6E);
  static const teal200 = Color(0xFF9DC4A0);
  static const teal100 = Color(0xFFC8E0CA);
  static const teal50  = Color(0xFFEAF4EB);

  // Alerta — vermelho vivo (nobre)
  static const red800 = Color(0xFF7A1515);
  static const red600 = Color(0xFFB82020);
  static const red400 = Color(0xFFDC3535);
  static const red200 = Color(0xFFF08080);
  static const red50  = Color(0xFFFDF0F0);

  // Atenção — âmbar dourado vivo
  static const amber800 = Color(0xFF7D4E00);
  static const amber600 = Color(0xFFC17900);
  static const amber400 = Color(0xFFE8A020);
  static const amber200 = Color(0xFFF5C968);
  static const amber50  = Color(0xFFFEF6E4);

  // Neutros — tom quente natural
  static const gray900 = Color(0xFF2A2A25);
  static const gray600 = Color(0xFF575750);
  static const gray400 = Color(0xFF878780);
  static const gray200 = Color(0xFFB5B4AC);
  static const gray100 = Color(0xFFD5D4CC);
  static const gray50  = Color(0xFFF0EEE8);

  static const white = Color(0xFFFFFFFF);
  static const background = Color(0xFFF3F0E8); // linho natural
  static const surface = Color(0xFFFDFCF8);    // branco quente
  static const border = Color(0xFFE3E0D4);      // areia
}

class PTTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PTColors.primary600,
        primary: PTColors.primary600,
        secondary: PTColors.teal400,
        error: PTColors.red600,
        surface: PTColors.surface,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: PTColors.background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: PTColors.gray900),
        displayMedium: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w600, color: PTColors.gray900),
        headlineLarge: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: PTColors.gray900),
        headlineMedium: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: PTColors.gray900),
        headlineSmall: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w500, color: PTColors.gray900),
        titleLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: PTColors.gray900),
        titleMedium: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: PTColors.gray900),
        titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: PTColors.gray900),
        bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: PTColors.gray600),
        bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: PTColors.gray600),
        bodySmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: PTColors.gray400),
        labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: PTColors.gray600),
        labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: PTColors.gray400),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: PTColors.surface,
        foregroundColor: PTColors.gray900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: PTColors.gray900),
        iconTheme: const IconThemeData(color: PTColors.gray900),
        surfaceTintColor: Colors.transparent,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PTColors.surface,
        selectedItemColor: PTColors.primary600,
        unselectedItemColor: PTColors.gray400,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: PTColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: PTColors.border, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PTColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PTColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PTColors.border, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PTColors.primary600, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: PTColors.gray400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PTColors.primary600,
          foregroundColor: PTColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PTColors.primary600,
          side: const BorderSide(color: PTColors.primary200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(color: PTColors.border, thickness: 0.5, space: 0),
      chipTheme: ChipThemeData(
        backgroundColor: PTColors.gray50,
        selectedColor: PTColors.primary50,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        side: const BorderSide(color: PTColors.border, width: 0.5),
      ),
    );
  }
}
