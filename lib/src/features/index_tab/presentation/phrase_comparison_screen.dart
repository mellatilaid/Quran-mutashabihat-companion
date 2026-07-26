import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran_mutashibihat_app/generated/l10n/app_localizations.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/arabic_line.dart';

/// Screen 4: Phrase Comparison - Shows all Quran-wide occurrences of a phrase.
class PhraseComparisonScreen extends ConsumerWidget {
  final int phraseId;

  const PhraseComparisonScreen({super.key, required this.phraseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(phraseComparisonProvider(phraseId));
    final phraseAsync = ref.watch(phraseProvider(phraseId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context).comparePhrase,
          style: GoogleFonts.newsreader(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: Column(
        children: [
          // Phrase stats header
          phraseAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $err'),
            ),
            data: (phrase) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1B2422)
                    : const Color(0xFFFAFAFA),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF3A3428)
                        : const Color(0xFFE2DAC7),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).occurrencesCount,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFA29F96)
                          : const Color(0xFF5C6B67),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${phrase.occurrenceCount} occurrences',
                        style: GoogleFonts.newsreader(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F6B62),
                        ),
                      ),
                      Text(
                        'in ${phrase.surahCount} surahs, ${phrase.ayahCount} ayahs',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFA29F96)
                              : const Color(0xFF5C6B67),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // List of occurrences
          Expanded(
            child: comparisonAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (occurrences) => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                itemCount: occurrences.length,
                itemBuilder: (context, index) {
                  final occurrence = occurrences[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      onTap: () {
                        context.go(
                          '/surah/${occurrence.surah}/ayah/${occurrence.surah}/${occurrence.ayah}',
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Location
                            Text(
                              '${occurrence.surah}:${occurrence.ayah}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F6B62),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Words with highlight
                            ArabicLine(words: occurrence.words, fontSize: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
