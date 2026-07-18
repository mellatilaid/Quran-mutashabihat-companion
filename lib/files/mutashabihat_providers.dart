import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_mutashibihat_app/files/models.dart';

import 'mutashabihat_repository.dart';

/// Single shared repository instance for the whole app.
final mutashabihatRepositoryProvider = Provider<MutashabihatRepository>((ref) {
  return MutashabihatRepository();
});

/// Screen 1 — Surah Index.
final surahsProvider = FutureProvider<List<Surah>>((ref) {
  final repo = ref.watch(mutashabihatRepositoryProvider);
  return repo.getSurahs();
});

/// Screen 2 — Mutashabihat ayahs for a given surah id.
/// Usage: ref.watch(mutashabihatAyahsProvider(2)) for Surat Al-Baqarah.
final mutashabihatAyahsProvider =
    FutureProvider.family<List<AyahListItem>, int>((ref, surah) {
      final repo = ref.watch(mutashabihatRepositoryProvider);
      return repo.getMutashabihatAyahs(surah);
    });

/// Identifies a single ayah — used as the .family argument for Screen 3
/// since a provider family key needs to be a single hashable value.
class AyahKey {
  final int surah;
  final int ayah;
  const AyahKey(this.surah, this.ayah);

  @override
  bool operator ==(Object other) =>
      other is AyahKey && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);
}

/// Screen 3 — full detail (words + highlights) for one tapped ayah.
/// Usage: ref.watch(ayahDetailProvider(AyahKey(2, 112)))
final ayahDetailProvider = FutureProvider.family<AyahDetail, AyahKey>((
  ref,
  key,
) {
  final repo = ref.watch(mutashabihatRepositoryProvider);
  return repo.getAyahDetail(key.surah, key.ayah);
});

/// Screen 4 — phrase metadata header.
/// Usage: ref.watch(phraseProvider(988))
final phraseProvider = FutureProvider.family<Phrase, int>((ref, phraseId) {
  final repo = ref.watch(mutashabihatRepositoryProvider);
  return repo.getPhrase(phraseId);
});

/// Screen 4 — every occurrence of the selected phrase, each ready to render
/// with its own highlighted words.
/// Usage: ref.watch(phraseComparisonProvider(988))
final phraseComparisonProvider =
    FutureProvider.family<List<PhraseOccurrenceDetail>, int>((ref, phraseId) {
      final repo = ref.watch(mutashabihatRepositoryProvider);
      return repo.getPhraseComparison(phraseId);
    });
