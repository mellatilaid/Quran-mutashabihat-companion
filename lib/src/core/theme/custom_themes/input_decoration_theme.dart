import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class SInputDecorationTheme {
  SInputDecorationTheme._();

  /// Input decoration theme for light mode
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightCard,
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    enabledBorder: _buildBoder(borderSideColor: AppColors.lightBorder),
    focusedBorder: _buildBoder(
      borderSideColor: AppColors.lightTeal,
      width: 2.0,
    ),
    errorBorder: _buildBoder(borderSideColor: AppColors.lightDanger),
    focusedErrorBorder: _buildBoder(
      borderSideColor: AppColors.lightDanger,
      width: 2.0,
    ),
    prefixIconColor: _getIconColor(
      enabledColor: AppColors.lightInkSoft,
      focusedColor: AppColors.lightTeal,
      errorColor: AppColors.lightDanger,
    ),
    suffixIconColor: _getIconColor(
      enabledColor: AppColors.lightInkSoft,
      focusedColor: AppColors.lightTeal,
      errorColor: AppColors.lightDanger,
    ),
  );

  /// Input decoration theme for dark mode
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkCard,
    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    enabledBorder: _buildBoder(borderSideColor: AppColors.darkBorder),
    focusedBorder: _buildBoder(borderSideColor: AppColors.darkTeal, width: 2.0),
    errorBorder: _buildBoder(borderSideColor: AppColors.darkDanger),
    focusedErrorBorder: _buildBoder(
      borderSideColor: AppColors.darkDanger,
      width: 2.0,
    ),
    prefixIconColor: _getIconColor(
      enabledColor: AppColors.darkInkSoft,
      focusedColor: AppColors.darkTeal,
      errorColor: AppColors.darkDanger,
    ),
    suffixIconColor: _getIconColor(
      enabledColor: AppColors.darkInkSoft,
      focusedColor: AppColors.darkTeal,
      errorColor: AppColors.darkDanger,
    ),
  );

  /// Builds an [OutlineInputBorder] with a circular border radius and a single
  /// [BorderSide] with the specified [borderSideColor] and [width].
  ///
  /// The [borderRadius] parameter is optional and defaults to 8.0 if not
  /// provided.
  ///
  /// The [width] parameter is optional and defaults to 1.3 if not provided.
  static OutlineInputBorder _buildBoder({
    required Color borderSideColor,
    double? borderRadius,
    double width = 1.3,
  }) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: borderSideColor, width: width),
      borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
    );
  }

  /// Returns a [WidgetStateColor] that resolves to one of the given colors
  /// based on the current state of the widget.
  /// See also:
  ///
  /// * [WidgetStateColor.resolveWith]
  static WidgetStateColor _getIconColor({
    required Color enabledColor,
    required Color focusedColor,
    required Color errorColor,
  }) {
    return WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.error)) {
        return errorColor; // Error state
      }
      if (states.contains(WidgetState.focused)) {
        return focusedColor; // Focused state
      }
      return enabledColor; // Default/enabled state
    });
  }
}
