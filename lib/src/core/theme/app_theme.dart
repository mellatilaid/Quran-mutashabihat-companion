import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'custom_themes/app_text_theme.dart';
import 'custom_themes/color_scheme.dart';
import 'custom_themes/icon_theme.dart';
import 'custom_themes/input_decoration_theme.dart';

class Apptheme {
  Apptheme._();

  /// Get theme based on brightness
  static ThemeData getTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    // Get colors based on brightness
    final backgroundColor = isDark ? AppColors.darkPaper : AppColors.lightPaper;
    final colorScheme = isDark
        ? AppColorScheme.darkColorScheme
        : AppColorScheme.lightColorScheme;
    final inputDecorationTheme = isDark
        ? SInputDecorationTheme.darkInputDecorationTheme
        : SInputDecorationTheme.lightInputDecorationTheme;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      primaryColor: isDark ? AppColors.darkTeal : AppColors.lightTeal,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: colorScheme,
      textTheme: AppTextTheme.getTextTheme(brightness),
      inputDecorationTheme: inputDecorationTheme,
      iconTheme: AppIconTheme.iconTheme,
      dividerColor: dividerColor,
    );
  }

  // Convenience getters for backward compatibility
  static ThemeData get lightTheme => getTheme(Brightness.light);
  static ThemeData get darkTheme => getTheme(Brightness.dark);
}
