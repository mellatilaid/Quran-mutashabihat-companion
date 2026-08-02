import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';
import 'package:quran_mutashibihat_app/src/core/router.dart';
import 'package:quran_mutashibihat_app/src/core/theme/app_theme.dart';

import 'core/extensions/app_dimentions.dart';
import 'core/providers/app_theme_provider.dart';

class MutashabihatApp extends ConsumerWidget {
  const MutashabihatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Mutashabihat Companion',
      debugShowCheckedModeBanner: false,
      theme: Apptheme.lightTheme.copyWith(
        extensions: [AppDimensionsTheme.main()],
      ),
      darkTheme: Apptheme.darkTheme.copyWith(
        extensions: [AppDimensionsTheme.main()],
      ),
      themeMode: themeMode,

      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
