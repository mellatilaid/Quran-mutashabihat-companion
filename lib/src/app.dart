import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_mutashibihat_app/src/core/providers.dart';
import 'package:quran_mutashibihat_app/src/core/router.dart';
import 'package:quran_mutashibihat_app/src/core/theme/app_theme.dart';

class MutashabihatApp extends ConsumerWidget {
  const MutashabihatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Mutashabihat Companion',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: const [],
      supportedLocales: const [Locale('ar')],
    );
  }
}
