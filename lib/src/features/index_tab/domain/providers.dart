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
