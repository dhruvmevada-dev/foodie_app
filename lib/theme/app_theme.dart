import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodieTheme {
  // 🎨 Vibrant Foodie Color Palette
  static const Color primary = Color(0xFFFF6B35);       // Spicy Orange
  static const Color secondary = Color(0xFFFFD23F);     // Saffron Yellow
  static const Color accent = Color(0xFF06D6A0);        // Mint Green
  static const Color accentPink = Color(0xFFEF476F);    // Berry Red
  static const Color accentPurple = Color(0xFF7209B7);  // Plum
  static const Color bgDark = Color(0xFF1A0A00);        // Deep Espresso
  static const Color bgCard = Color(0xFF2D1506);        // Dark Mocha
  static const Color bgCardLight = Color(0xFF3D2010);   // Warm Brown
  static const Color textPrimary = Color(0xFFFFF8F0);   // Cream White
  static const Color textSecondary = Color(0xFFD4A57A); // Warm Tan
  static const Color textMuted = Color(0xFF8A6040);     // Muted Brown
  static const Color divider = Color(0xFF4A2E18);       // Divider Brown
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD23F);
  static const Color error = Color(0xFFEF476F);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF9A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2D1506), Color(0xFF3D2010)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF1A0A00), Color(0xFF2D1506), Color(0xFF1A0A00)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: bgCard,
        error: error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          color: textPrimary, fontSize: 32, fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          color: textPrimary, fontSize: 26, fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          color: textPrimary, fontSize: 22, fontWeight: FontWeight.w700,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.poppins(
          color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.poppins(
          color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.poppins(
          color: textSecondary, fontSize: 14, fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.poppins(
          color: textSecondary, fontSize: 13, fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.poppins(
          color: textPrimary, fontSize: 13, fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: GoogleFonts.poppins(color: textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: bgCardLight,
        selectedColor: primary.withOpacity(0.3),
        labelStyle: GoogleFonts.poppins(color: textSecondary, fontSize: 12),
        side: const BorderSide(color: divider),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: textPrimary, fontSize: 22, fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgCard,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        elevation: 0,
      ),
    );
  }
}
