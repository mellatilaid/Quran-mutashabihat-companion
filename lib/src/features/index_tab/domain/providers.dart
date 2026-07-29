import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models.dart';
import '../data/index_repo.dart';

final indexRepoProvider = Provider<IndexRepo>((ref) {
  return IndexRepo();
});

final surahsProvider = FutureProvider.autoDispose<List<Surah>>((ref) async {
  final repo = ref.watch(indexRepoProvider);
  return repo.getSurahs();
});
