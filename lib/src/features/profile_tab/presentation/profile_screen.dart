import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';

import '../../../core/providers.dart';

/// Profile Tab Screen — settings, statistics, and app information.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final fontSize = ref.watch(arabicFontSizeProvider);
    final favoriteCountAsync = ref.watch(favoriteCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.profile,
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0F6B62).withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: favoriteCountAsync.when(
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, _) => Text(
                          '0',
                          style: GoogleFonts.newsreader(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F6B62),
                          ),
                        ),
                        data: (count) => Text(
                          '$count',
                          style: GoogleFonts.newsreader(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F6B62),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Favorite Ayahs',
                    style: GoogleFonts.newsreader(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFFA29F96)
                          : const Color(0xFF5C6B67),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // APPEARANCE section
          Text(
            'APPEARANCE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA29F96) : const Color(0xFF5C6B67),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Dark mode toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: isDark
                            ? const Color(0xFFEDEDE4)
                            : const Color(0xFF20302C),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Dark Mode',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFFEDEDE4)
                              : const Color(0xFF20302C),
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                    activeThumbColor: const Color(0xFF0F6B62),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Font size controls
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.text_fields),
                      const SizedBox(width: 12),
                      Text(
                        'Arabic Text Size',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFEDEDE4)
                              : const Color(0xFF20302C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Small button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(arabicFontSizeProvider.notifier)
                                .setFontSize(17.0);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fontSize == 17.0
                                ? const Color(0xFF0F6B62)
                                : isDark
                                ? const Color(0xFF1B2422)
                                : const Color(0xFFFAFAFA),
                            foregroundColor: fontSize == 17.0
                                ? Colors.white
                                : isDark
                                ? const Color(0xFFEDEDE4)
                                : const Color(0xFF20302C),
                          ),
                          child: Text(
                            'A',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Medium button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(arabicFontSizeProvider.notifier)
                                .setFontSize(20.0);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fontSize == 20.0
                                ? const Color(0xFF0F6B62)
                                : isDark
                                ? const Color(0xFF1B2422)
                                : const Color(0xFFFAFAFA),
                            foregroundColor: fontSize == 20.0
                                ? Colors.white
                                : isDark
                                ? const Color(0xFFEDEDE4)
                                : const Color(0xFF20302C),
                          ),
                          child: Text(
                            'A',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Large button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(arabicFontSizeProvider.notifier)
                                .setFontSize(22.0);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: fontSize == 22.0
                                ? const Color(0xFF0F6B62)
                                : isDark
                                ? const Color(0xFF1B2422)
                                : const Color(0xFFFAFAFA),
                            foregroundColor: fontSize == 22.0
                                ? Colors.white
                                : isDark
                                ? const Color(0xFFEDEDE4)
                                : const Color(0xFF20302C),
                          ),
                          child: Text(
                            'A',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // CONFIDENCE BY SURAH section (placeholder)
          Text(
            'CONFIDENCE BY SURAH',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA29F96) : const Color(0xFF5C6B67),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Your progress by surah will appear here after you complete test sessions.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFFA29F96)
                      : const Color(0xFF5C6B67),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // PROGRESS section
          Text(
            'PROGRESS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFA29F96) : const Color(0xFF5C6B67),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Reset test history
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: const Icon(Icons.history),
              title: Text(
                'Reset Test History',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFEDEDE4)
                      : const Color(0xFF20302C),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement reset test history with confirmation dialog
              },
            ),
          ),
          const SizedBox(height: 8),

          // About this app
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: const Icon(Icons.info_outline),
              title: Text(
                'About This App',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark
                      ? const Color(0xFFEDEDE4)
                      : const Color(0xFF20302C),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement about dialog or screen
              },
            ),
          ),
        ],
      ),
    );
  }
}
