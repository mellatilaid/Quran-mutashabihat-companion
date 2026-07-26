import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/src/core/constants/design_tokens.dart';

/// Light theme for the Mutashabihat Companion app
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,

  // Primary and surface colors
  primaryColor: lightTeal,
  scaffoldBackgroundColor: lightPaper,

  // Color scheme
  colorScheme: ColorScheme.light(
    primary: lightTeal,
    secondary: lightGold,
    tertiary: lightRose,
    surface: lightCard,
    surfaceContainer: lightTealSoft,
    error: lightDanger,
    onError: Colors.white,
    scrim: lightInk,
  ),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: lightTeal,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: lightCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
      side: const BorderSide(color: lightBorder, width: 1),
    ),
  ),

  // Text theme using Google Fonts
  textTheme: TextTheme(
    // Display styles - Newsreader 600
    displayLarge: GoogleFonts.newsreader(
      fontSize: fontSize3xl,
      fontWeight: FontWeight.w600,
      color: lightInk,
    ),
    displayMedium: GoogleFonts.newsreader(
      fontSize: fontSize2xl,
      fontWeight: FontWeight.w600,
      color: lightInk,
    ),
    displaySmall: GoogleFonts.newsreader(
      fontSize: fontSizeXxl,
      fontWeight: FontWeight.w600,
      color: lightInk,
    ),

    // Headline styles - Newsreader 600
    headlineLarge: GoogleFonts.newsreader(
      fontSize: fontSize2xl,
      fontWeight: FontWeight.w600,
      color: lightInk,
    ),
    headlineMedium: GoogleFonts.newsreader(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w600,
      color: lightInk,
    ),
    headlineSmall: GoogleFonts.newsreader(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w600,
      color: lightInk,
    ),

    // Title styles - Amiri 400
    titleLarge: GoogleFonts.amiri(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w400,
      color: lightInk,
    ),
    titleMedium: GoogleFonts.amiri(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w400,
      color: lightInk,
    ),
    titleSmall: GoogleFonts.amiri(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w400,
      color: lightInk,
    ),

    // Body styles - Amiri 400
    bodyLarge: GoogleFonts.amiri(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w400,
      color: lightInk,
    ),
    bodyMedium: GoogleFonts.amiri(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w400,
      color: lightInk,
    ),
    bodySmall: GoogleFonts.amiri(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w400,
      color: lightInkSoft,
    ),

    // Label styles - Inter 600
    labelLarge: GoogleFonts.inter(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w600,
      color: lightInk,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: fontSizeSm,
      fontWeight: FontWeight.w600,
      color: lightInk,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: fontSizeXs,
      fontWeight: FontWeight.w600,
      color: lightInkSoft,
    ),
  ),

  // Input decoration theme for text fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: lightCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: lightBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: lightBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: lightTeal, width: 2),
    ),
  ),

  // Button themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: lightTeal,
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
      foregroundColor: lightTeal,
      side: const BorderSide(color: lightTeal),
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
  primaryColor: darkTeal,
  scaffoldBackgroundColor: darkPaper,

  // Color scheme
  colorScheme: ColorScheme.dark(
    primary: darkTeal,
    secondary: darkGold,
    tertiary: darkRose,
    surface: darkCard,
    surfaceContainer: darkTealSoft,
    error: darkDanger,
    onError: Colors.white,
    scrim: darkInk,
  ),

  // AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: lightTeal, // Keep light teal for consistency
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  ),

  // Card theme
  cardTheme: CardThemeData(
    color: darkCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLg),
      side: const BorderSide(color: darkBorder, width: 1),
    ),
  ),

  // Text theme using Google Fonts
  textTheme: TextTheme(
    // Display styles - Newsreader 600
    displayLarge: GoogleFonts.newsreader(
      fontSize: fontSize3xl,
      fontWeight: FontWeight.w600,
      color: darkInk,
    ),
    displayMedium: GoogleFonts.newsreader(
      fontSize: fontSize2xl,
      fontWeight: FontWeight.w600,
      color: darkInk,
    ),
    displaySmall: GoogleFonts.newsreader(
      fontSize: fontSizeXxl,
      fontWeight: FontWeight.w600,
      color: darkInk,
    ),

    // Headline styles - Newsreader 600
    headlineLarge: GoogleFonts.newsreader(
      fontSize: fontSize2xl,
      fontWeight: FontWeight.w600,
      color: darkInk,
    ),
    headlineMedium: GoogleFonts.newsreader(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w600,
      color: darkInk,
    ),
    headlineSmall: GoogleFonts.newsreader(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w600,
      color: darkInk,
    ),

    // Title styles - Amiri 400
    titleLarge: GoogleFonts.amiri(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w400,
      color: darkInk,
    ),
    titleMedium: GoogleFonts.amiri(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w400,
      color: darkInk,
    ),
    titleSmall: GoogleFonts.amiri(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w400,
      color: darkInk,
    ),

    // Body styles - Amiri 400
    bodyLarge: GoogleFonts.amiri(
      fontSize: fontSizeXl,
      fontWeight: FontWeight.w400,
      color: darkInk,
    ),
    bodyMedium: GoogleFonts.amiri(
      fontSize: fontSizeLg,
      fontWeight: FontWeight.w400,
      color: darkInk,
    ),
    bodySmall: GoogleFonts.amiri(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w400,
      color: darkInkSoft,
    ),

    // Label styles - Inter 600
    labelLarge: GoogleFonts.inter(
      fontSize: fontSizeBase,
      fontWeight: FontWeight.w600,
      color: darkInk,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: fontSizeSm,
      fontWeight: FontWeight.w600,
      color: darkInk,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: fontSizeXs,
      fontWeight: FontWeight.w600,
      color: darkInkSoft,
    ),
  ),

  // Input decoration theme for text fields
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: darkCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      borderSide: const BorderSide(color: darkTeal, width: 2),
    ),
  ),

  // Button themes
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: darkTeal,
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
      foregroundColor: darkTeal,
      side: const BorderSide(color: darkTeal),
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
