import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';

import '../../../core/providers.dart';

/// Screen 2: Mutashabihat Ayahs - Lists ayahs in a surah that contain shared phrases.
class MutashabihatAyahsScreen extends ConsumerWidget {
  final int surahId;

  const MutashabihatAyahsScreen({super.key, required this.surahId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(mutashabihatAyahsProvider(surahId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'سورة $surahId',
          style: GoogleFonts.newsreader(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: ayahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (ayahs) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          itemCount: ayahs.length,
          itemBuilder: (context, index) {
            final ayah = ayahs[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                title: Text(
                  ayah.text,
                  style: GoogleFonts.amiri(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFFEDEDE4)
                        : const Color(0xFF20302C),
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Ayah ${ayah.ayah}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFFA29F96)
                        : const Color(0xFF5C6B67),
                  ),
                ),
                onTap: () {
                  context.go('/surah/$surahId/ayah/$surahId/${ayah.ayah}');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
