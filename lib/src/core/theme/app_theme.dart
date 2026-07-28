import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/src/core/constants/app_colors.dart';
import 'package:quran_mutashibihat_app/src/core/constants/design_tokens.dart';

/// Light theme for the Mutashabihat Companion app
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,

  // Primary and surface colors
  primaryColor: AppColors.lightTeal,
  scaffoldBackgroundColor: AppColors.lightPaper,

  // Color scheme
  colorScheme: ColorScheme.light(
    primary: AppColors.lightTeal,
    secondary: AppColors.lightGold,
    tertiary: AppColors.lightRose,
    surface: AppColors.lightCard,
    surfaceContainer: AppColors.lightTealSoft,
    error: AppColors.lightDanger,
    onError: Colors.white,
    scrim: AppColors.lightInk,
  ),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F6B62), // lightTeal
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: AppColors.lightCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
      side: const BorderSide(color: Color(0xFFE2DAC7), width: 1), // lightBorder
    ),
  ),

  // Text theme using Google Fonts
  textTheme: TextTheme(
    // Display styles - Newsreader 600
    displayLarge: GoogleFonts.newsreader(
      fontSize: fontSize3xl,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInk,
    ),
    displayMedium: GoogleFonts.newsreader(
      fontSize: fontSize2xl,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInk,
    ),
    displaySmall: GoogleFonts.newsreader(
      fontSize: fontSizeXxl,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInk,
    ),

    // Headline styles - Newsreader 600
    headlineLarge: GoogleFonts.newsreader(
      fontSize: fontSize2xl,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInk,
    ),
    headlineMedium: GoogleFonts.newsreader(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInk,
    ),
    headlineSmall: GoogleFonts.newsreader(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInk,
    ),

    // Title styles - Amiri 400
    titleLarge: GoogleFonts.amiri(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w400,
      color: AppColors.lightInk,
    ),
    titleMedium: GoogleFonts.amiri(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w400,
      color: AppColors.lightInk,
    ),
    titleSmall: GoogleFonts.amiri(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w400,
      color: AppColors.lightInk,
    ),

    // Body styles - Amiri 400
    bodyLarge: GoogleFonts.amiri(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w400,
      color: AppColors.lightInk,
    ),
    bodyMedium: GoogleFonts.amiri(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w400,
      color: AppColors.lightInk,
    ),
    bodySmall: GoogleFonts.amiri(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w400,
      color: AppColors.lightInkSoft,
    ),

    // Label styles - Inter 600
    labelLarge: GoogleFonts.inter(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInk,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: fontSizeSm,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInk,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: fontSizeXs,
      fontWeight: FontWeight.w600,
      color: AppColors.lightInkSoft,
    ),
  ),

  // Input decoration theme for text fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: Color(0xFFE2DAC7)), // lightBorder
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: Color(0xFFE2DAC7)), // lightBorder
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(
        color: Color(0xFF0F6B62),
        width: 2,
      ), // lightTeal
    ),
  ),

  // Button themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightTeal,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingLg,
        vertical: spacingMd,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.lightTeal,
      side: const BorderSide(color: Color(0xFF0F6B62)), // lightTeal
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingLg,
        vertical: spacingMd,
      ),
    ),
  ),
);

/// Dark theme for the Mutashabihat Companion app
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,

  // Primary and surface colors
  primaryColor: AppColors.darkTeal,
  scaffoldBackgroundColor: AppColors.darkPaper,

  // Color scheme
  colorScheme: ColorScheme.dark(
    primary: AppColors.darkTeal,
    secondary: AppColors.darkGold,
    tertiary: AppColors.darkRose,
    surface: AppColors.darkCard,
    surfaceContainer: AppColors.darkTealSoft,
    error: AppColors.darkDanger,
    onError: Colors.white,
    scrim: AppColors.darkInk,
  ),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F6B62), // Keep light teal for consistency
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: AppColors.darkCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
      side: const BorderSide(color: Color(0xFF3A3428), width: 1), // darkBorder
    ),
  ),

  // Text theme using Google Fonts
  textTheme: TextTheme(
    // Display styles - Newsreader 600
    displayLarge: GoogleFonts.newsreader(
      fontSize: fontSize3xl,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),
    displayMedium: GoogleFonts.newsreader(
      fontSize: fontSize2xl,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),
    displaySmall: GoogleFonts.newsreader(
      fontSize: fontSizeXxl,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),

    // Headline styles - Newsreader 600
    headlineLarge: GoogleFonts.newsreader(
      fontSize: fontSize2xl,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),
    headlineMedium: GoogleFonts.newsreader(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),
    headlineSmall: GoogleFonts.newsreader(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),

    // Title styles - Amiri 400
    titleLarge: GoogleFonts.amiri(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w400,
      color: AppColors.darkInk,
    ),
    titleMedium: GoogleFonts.amiri(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w400,
      color: AppColors.darkInk,
    ),
    titleSmall: GoogleFonts.amiri(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w400,
      color: AppColors.darkInk,
    ),

    // Body styles - Amiri 400
    bodyLarge: GoogleFonts.amiri(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w400,
      color: AppColors.darkInk,
    ),
    bodyMedium: GoogleFonts.amiri(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w400,
      color: AppColors.darkInk,
    ),
    bodySmall: GoogleFonts.amiri(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w400,
      color: AppColors.darkInkSoft,
    ),

    // Label styles - Inter 600
    labelLarge: GoogleFonts.inter(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: fontSizeSm,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInk,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: fontSizeXs,
      fontWeight: FontWeight.w600,
      color: AppColors.darkInkSoft,
    ),
  ),

  // Input decoration theme for text fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: Color(0xFF3A3428)), // darkBorder
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: Color(0xFF3A3428)), // darkBorder
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(
        color: Color(0xFF4FBFAE),
        width: 2,
      ), // darkTeal
    ),
  ),

  // Button themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkTeal,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingLg,
        vertical: spacingMd,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.darkTeal,
      side: const BorderSide(color: Color(0xFF4FBFAE)), // darkTeal
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: spacingLg,
        vertical: spacingMd,
      ),
    ),
  ),
);
