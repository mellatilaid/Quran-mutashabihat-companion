import 'package:flutter/material.dart';
import 'package:quran_mutashibihat_app/src/core/extensions/app_dimentions.dart';

import '../../../l10n/app_localizations.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  AppDimensionsTheme get dimensionsTheme =>
      theme.extension<AppDimensionsTheme>()!;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
