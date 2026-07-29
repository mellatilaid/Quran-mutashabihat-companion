import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models.dart';
import '../data/index_repo.dart';
import 'models/ayah_key.dart';

final indexRepoProvider = Provider<IndexRepo>((ref) {
  return IndexRepo();
});

final surahsProvider = FutureProvider.autoDispose<List<Surah>>((ref) async {
  final repo = ref.watch(indexRepoProvider);
  return repo.getSurahs();
});

final surahDetailsProvider = FutureProvider.autoDispose
    .family<List<AyahListItem>, int>((ref, surahIndex) async {
      final repo = ref.watch(indexRepoProvider);
      return repo.getMutashabihatAyahs(surahIndex);
    });

final ayahDetailsProvider = FutureProvider.autoDispose
    .family<AyahDetail, AyahKey>((ref, ayahKey) async {
      final repo = ref.watch(indexRepoProvider);
      return repo.getAyahDetail(ayahKey.surah, ayahKey.ayah);
    });

final phraseProvider = FutureProvider.family<Phrase, int>((ref, phraseId) {
  final repo = ref.watch(indexRepoProvider);
  return repo.getPhrase(phraseId);
});

final phraseComparisonProvider =
    FutureProvider.family<List<PhraseOccurrenceDetail>, int>((ref, phraseId) {
      final repo = ref.watch(indexRepoProvider);
      return repo.getPhraseComparison(phraseId);
    });
