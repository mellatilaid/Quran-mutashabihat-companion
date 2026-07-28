import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_colors.dart';
import '../../constants/design_tokens.dart';

class STextThemeV2 {
  STextThemeV2._();

  /// Get text theme based on brightness
  static TextTheme getTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final textPrimaryColor = isDark ? AppColors.darkInk : AppColors.lightInk;
    final textSecondaryColor = isDark
        ? AppColors.darkInkSoft
        : AppColors.lightInkSoft;

    return TextTheme(
      // Display styles - Newsreader 600
      displayLarge: GoogleFonts.newsreader(
        fontSize: fontSize3xl,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      displayMedium: GoogleFonts.newsreader(
        fontSize: fontSize2xl,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      displaySmall: GoogleFonts.newsreader(
        fontSize: fontSizeXxl,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),

      // Headline styles - Newsreader 600
      headlineLarge: GoogleFonts.newsreader(
        fontSize: fontSize2xl,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineMedium: GoogleFonts.newsreader(
        fontSize: fontSizeXl,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      headlineSmall: GoogleFonts.newsreader(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),

      // Title styles - Amiri 400
      titleLarge: GoogleFonts.amiri(
        fontSize: fontSizeXl,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      titleMedium: GoogleFonts.amiri(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      titleSmall: GoogleFonts.amiri(
        fontSize: fontSizeBase,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),

      // Body styles - Amiri 400
      bodyLarge: GoogleFonts.amiri(
        fontSize: fontSizeXl,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      bodyMedium: GoogleFonts.amiri(
        fontSize: fontSizeLg,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
      ),
      bodySmall: GoogleFonts.amiri(
        fontSize: fontSizeBase,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
      ),

      // Label styles - Inter 600
      labelLarge: GoogleFonts.inter(
        fontSize: fontSizeBase,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: fontSizeSm,
        fontWeight: FontWeight.w600,
        color: textPrimaryColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: fontSizeXs,
        fontWeight: FontWeight.w600,
        color: textSecondaryColor,
      ),
    );
  }
}
