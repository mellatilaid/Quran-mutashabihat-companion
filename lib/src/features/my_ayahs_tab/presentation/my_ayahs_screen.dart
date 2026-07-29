import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/l10n/app_localizations.dart';

import '../../../core/providers/providers.dart';

/// My Ayahs Tab Screen — displays bookmarked difficult ayahs for study.
class MyAyahsScreen extends ConsumerWidget {
  const MyAyahsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myAyahsAsync = ref.watch(myAyahsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).myAyahs,
          style: GoogleFonts.newsreader(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/my-ayahs/add'),
          ),
        ],
      ),
      body: myAyahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (myAyahs) {
          if (myAyahs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: isDark
                        ? const Color(0xFFA29F96)
                        : const Color(0xFF5C6B67),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No ayahs bookmarked yet',
                    style: GoogleFonts.newsreader(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFEDEDE4)
                          : const Color(0xFF20302C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add difficult ayahs you want to study',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFFA29F96)
                          : const Color(0xFF5C6B67),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: myAyahs.length,
            itemBuilder: (context, index) {
              final myAyah = myAyahs[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  leading: Icon(
                    Icons.bookmark,
                    color: const Color(0xFF0F6B62), // teal
                  ),
                  title: Text(
                    '${myAyah.surahId}:${myAyah.ayahNum}',
                    style: GoogleFonts.newsreader(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFEDEDE4)
                          : const Color(0xFF20302C),
                    ),
                  ),
                  subtitle: myAyah.note != null
                      ? Text(
                          myAyah.note!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFA29F96)
                                : const Color(0xFF5C6B67),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          'Added ${myAyah.createdAt.toString().split(' ')[0]}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? const Color(0xFFA29F96)
                                : const Color(0xFF5C6B67),
                          ),
                        ),
                  onTap: () {
                    context.go('/my-ayahs/${myAyah.surahId}/${myAyah.ayahNum}');
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await ref
                          .read(myAyahsProvider.notifier)
                          .removeAyah(myAyah.surahId, myAyah.ayahNum);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
