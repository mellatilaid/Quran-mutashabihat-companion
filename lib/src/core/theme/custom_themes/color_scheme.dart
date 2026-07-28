import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class AppColorScheme {
  AppColorScheme._();

  ///light color scheme for the app
  static ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppColors.lightTeal,
    onPrimary: Colors.white,
    surface: AppColors.lightCard,
    onSurface: AppColors.lightInk,
    surfaceContainer: AppColors.lightTealSoft,
    surfaceContainerLowest: AppColors.lightCard,
    surfaceContainerLow: AppColors.lightCard,
    surfaceContainerHigh: AppColors.lightTealSoft,
    surfaceContainerHighest: AppColors.lightPaper,
    surfaceBright: AppColors.lightCard,
    inverseSurface: AppColors.lightInk,
    onSurfaceVariant: AppColors.lightInkSoft,
    secondary: AppColors.lightGold,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.lightGoldSoft,
    onSecondaryContainer: AppColors.lightGold,
    tertiary: AppColors.lightRose,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.lightRoseSoft,
    onTertiaryContainer: AppColors.lightRose,
    error: AppColors.lightDanger,
    onError: Colors.white,
    errorContainer: AppColors.lightDangerSoft,
    onErrorContainer: AppColors.lightDanger,
    outline: AppColors.lightBorder,
    outlineVariant: AppColors.lightBorder,
    scrim: Colors.black,
  );

  ///dark color scheme for the app
  static ColorScheme darkColorScheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: AppColors.darkTeal,
    onPrimary: Colors.white,
    surface: AppColors.darkCard,
    onSurface: AppColors.darkInk,
    surfaceContainer: AppColors.darkTealSoft,
    surfaceContainerLowest: AppColors.darkCard,
    surfaceContainerLow: AppColors.darkCard,
    surfaceContainerHigh: AppColors.darkTealSoft,
    surfaceContainerHighest: AppColors.darkPaper,
    surfaceBright: AppColors.darkCard,
    inverseSurface: AppColors.darkInk,
    onSurfaceVariant: AppColors.darkInkSoft,
    secondary: AppColors.darkGold,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.darkGoldSoft,
    onSecondaryContainer: AppColors.darkGold,
    tertiary: AppColors.darkRose,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.darkRoseSoft,
    onTertiaryContainer: AppColors.darkRose,
    error: AppColors.darkDanger,
    onError: Colors.white,
    errorContainer: AppColors.darkDangerSoft,
    onErrorContainer: AppColors.darkDanger,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkBorder,
    scrim: Colors.black,
  );
}
