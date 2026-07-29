import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quran_mutashibihat_app/src/core/models.dart';
import 'package:quran_mutashibihat_app/src/core/models/user_data_models.dart';
import 'package:quran_mutashibihat_app/src/core/services/mutashabihat_repository.dart';
import 'package:quran_mutashibihat_app/src/core/services/user_data_database_helper.dart';
import 'package:quran_mutashibihat_app/src/core/services/user_data_repository.dart';

import '../../features/index_tab/domain/models/ayah_key.dart';

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

/// Arabic font size provider (17.0, 20.0, 22.0)
/// This manages the app-wide Arabic text size setting.
class _FontSizeNotifier extends Notifier<double> {
  @override
  double build() => 20.0;

  void setFontSize(double size) {
    if ([17.0, 20.0, 22.0].contains(size)) {
      state = size;
    }
  }

  void increase() {
    if (state < 22.0) {
      state += 3.0;
    }
  }

  void decrease() {
    if (state > 17.0) {
      state -= 3.0;
    }
  }
}

final arabicFontSizeProvider = NotifierProvider<_FontSizeNotifier, double>(
  _FontSizeNotifier.new,
);

// ============ User Data Providers (Favorites, Bookmarks) ============

/// User data repository provider
final userDataRepositoryProvider = Provider<UserDataRepository>((ref) {
  final databaseHelper = UserDataDatabaseHelper();
  return UserDataRepository(databaseHelper: databaseHelper);
});

/// All favorite ayahs
final favoritesProvider = FutureProvider<List<FavoriteAyah>>((ref) {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getFavorites();
});

/// Check if a specific ayah is favorited
/// Usage: ref.watch(isFavoriteProvider((2, 112)))
final isFavoriteProvider = FutureProvider.family<bool, (int, int)>((
  ref,
  params,
) async {
  final (surahId, ayahNum) = params;
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.isFavorite(surahId, ayahNum);
});

/// Total count of favorite ayahs
final favoriteCountProvider = FutureProvider<int>((ref) {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getFavoriteCount();
});

/// Favorites for a specific surah
/// Usage: ref.watch(favoritesBySurahProvider(2))
final favoritesBySurahProvider = FutureProvider.family<List<FavoriteAyah>, int>(
  (ref, surahId) {
    final repo = ref.watch(userDataRepositoryProvider);
    return repo.getFavoritesBySurah(surahId);
  },
);

// ============ My Ayahs Providers ============

/// State notifier for managing my ayahs list
class MyAyahsNotifier extends StateNotifier<AsyncValue<List<MyAyahListItem>>> {
  final UserDataRepository _repo;

  MyAyahsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _loadAyahs();
  }

  Future<void> _loadAyahs() async {
    try {
      final ayahs = await _repo.getMyAyahs();
      state = AsyncValue.data(ayahs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Add an ayah to my ayahs and update state
  Future<void> addAyah(int surahId, int ayahNum, {String? note}) async {
    try {
      await _repo.addToMyAyahs(surahId, ayahNum, note: note);
      await _loadAyahs();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Remove an ayah from my ayahs and update state
  Future<void> removeAyah(int surahId, int ayahNum) async {
    try {
      await _repo.removeFromMyAyahs(surahId, ayahNum);
      await _loadAyahs();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update an ayah's note and update state
  Future<void> updateAyahNote(int surahId, int ayahNum, String? note) async {
    try {
      await _repo.updateMyAyahNote(surahId, ayahNum, note);
      await _loadAyahs();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// All bookmarked (difficult) ayahs — automatically updates when data changes
final myAyahsProvider =
    StateNotifierProvider<MyAyahsNotifier, AsyncValue<List<MyAyahListItem>>>((
      ref,
    ) {
      final repo = ref.watch(userDataRepositoryProvider);
      return MyAyahsNotifier(repo);
    });

/// Check if a specific ayah is bookmarked
/// Usage: ref.watch(isInMyAyahsProvider((2, 112)))
final isInMyAyahsProvider = FutureProvider.family<bool, (int, int)>((
  ref,
  params,
) async {
  final (surahId, ayahNum) = params;
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.isInMyAyahs(surahId, ayahNum);
});

/// Total count of bookmarked ayahs
final myAyahsCountProvider = FutureProvider<int>((ref) {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getMyAyahsCount();
});

/// My Ayahs for a specific surah
/// Usage: ref.watch(myAyahsBySurahProvider(2))
final myAyahsBySurahProvider = FutureProvider.family<List<MyAyahListItem>, int>(
  (ref, surahId) {
    final repo = ref.watch(userDataRepositoryProvider);
    return repo.getMyAyahsBySurah(surahId);
  },
);

/// Search ayahs by query
/// Usage: ref.watch(searchAyahsProvider("محمد"))
final searchAyahsProvider = FutureProvider.family<List<AyahListItem>, String>((
  ref,
  query,
) {
  final mutashabihatRepo = ref.watch(mutashabihatRepositoryProvider);
  return mutashabihatRepo.searchAyahs(query);
});
