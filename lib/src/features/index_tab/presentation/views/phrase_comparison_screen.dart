import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/build_context_extensions.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/arabic_line.dart';

/// Screen 4: Phrase Comparison - Shows all Quran-wide occurrences of a phrase.
class PhraseComparisonScreen extends ConsumerWidget {
  final int phraseId;

  const PhraseComparisonScreen({super.key, required this.phraseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(phraseComparisonProvider(phraseId));
    final phraseAsync = ref.watch(phraseProvider(phraseId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.comparePhrase,
          style: context.textTheme.displayMedium?.copyWith(
            color: context.colorScheme.onPrimary,
          ),
        ),
        elevation: 0,
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
              child: Text(context.l10n.errorMessage(err.toString())),
            ),
            data: (phrase) => Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: context.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.occurrencesCount,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${phrase.occurrenceCount} ${context.l10n.occurrences}',
                        style: context.textTheme.displaySmall?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      ),
                      Text(
                        context.l10n.inSurahsAndAyahs(phrase.surahCount, phrase.ayahCount),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
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
              error: (err, _) => Center(child: Text(context.l10n.errorMessage(err.toString()))),
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
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colorScheme.primary,
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
