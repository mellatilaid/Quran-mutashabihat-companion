// Minimal, illustrative widgets — enough to show how each provider is
// consumed. Not a full UI; drop these patterns into your real screens.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mutashabihat_providers.dart';

// ---------------------------------------------------------------------
// Screen 1 — Surah Index
// ---------------------------------------------------------------------
class SurahIndexScreen extends ConsumerWidget {
  const SurahIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mutashabihat Companion')),
      body: surahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load surahs: $e')),
        data: (surahs) => ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (context, i) {
            final s = surahs[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${s.id}')),
              title: Text('${s.nameArabic}   ${s.nameSimple}'),
              subtitle: Text(
                '${s.mutashabihatAyahCount} Mutashabihat ayahs and ${s.versesCount - 1} total ayahs',
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MutashabihatAyahsScreen(
                    surah: s.id,
                    nameArabic: s.nameArabic,
                    nameSimple: s.nameSimple,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Screen 2 — Mutashabihat Ayahs in a Surah (plain text)
// ---------------------------------------------------------------------
class MutashabihatAyahsScreen extends ConsumerWidget {
  final int surah;
  final String nameArabic;
  final String nameSimple;
  const MutashabihatAyahsScreen({
    super.key,
    required this.surah,
    required this.nameArabic,
    required this.nameSimple,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ayahsAsync = ref.watch(mutashabihatAyahsProvider(surah));

    return Scaffold(
      appBar: AppBar(title: Text(nameArabic)),
      body: ayahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load ayahs: $e')),
        data: (ayahs) => ListView.builder(
          itemCount: ayahs.length,
          itemBuilder: (context, i) {
            final a = ayahs[i];
            return ListTile(
              leading: Text('${a.ayah}'),
              title: Text(
                a.text,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(fontSize: 20),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AyahDetailScreen(surah: a.surah, ayah: a.ayah),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Screen 3 — Ayah Details, with words highlighted
// ---------------------------------------------------------------------
class AyahDetailScreen extends ConsumerWidget {
  final int surah;
  final int ayah;
  const AyahDetailScreen({super.key, required this.surah, required this.ayah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(ayahDetailProvider(AyahKey(surah, ayah)));

    return Scaffold(
      appBar: AppBar(title: Text('Ayah $surah:$ayah')),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load ayah: $e')),
        data: (detail) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Highlighted ayah: each word painted individually.
              Directionality(
                textDirection: TextDirection.rtl,
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: detail.words.map((w) {
                    final highlighted =
                        detail.isHighlighted(w.wordIndex) ?? false;
                    return Text(
                      w.text,
                      style: GoogleFonts.amiri(
                        fontSize: 22,
                        backgroundColor: highlighted
                            ? Colors.amber.shade200
                            : null,
                        fontWeight: highlighted
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Similar phrases found here:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...detail.phraseIds.map(
                (phraseId) => ListTile(
                  title: Text('Phrase #$phraseId'),
                  trailing: const Icon(Icons.compare_arrows),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PhraseComparisonScreen(phraseId: phraseId),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Screen 4 — Phrase Comparison, every occurrence highlighted
// ---------------------------------------------------------------------
class PhraseComparisonScreen extends ConsumerWidget {
  final int phraseId;
  const PhraseComparisonScreen({super.key, required this.phraseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occurrencesAsync = ref.watch(phraseComparisonProvider(phraseId));

    return Scaffold(
      appBar: AppBar(title: Text('Phrase #$phraseId — Comparison')),
      body: occurrencesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load comparison: $e')),
        data: (occurrences) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: occurrences.length,
          itemBuilder: (context, i) {
            final o = occurrences[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${o.surah}:${o.ayah}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: o.words.map((w) {
                          final highlighted = o.isHighlighted(w.wordIndex);
                          return Text(
                            w.text,
                            style: TextStyle(
                              fontSize: 20,
                              backgroundColor: highlighted
                                  ? Colors.amber.shade200
                                  : null,
                              fontWeight: highlighted
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // TODO (SDD §7): mnemonic tip / explanation for this
                    // occurrence goes here once the mnemonic_tips table exists.
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
