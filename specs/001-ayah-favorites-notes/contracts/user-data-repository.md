# Contract: `UserDataRepository` (favorites + notes) & Riverpod providers

This app has no network API; its "interface contract" is the repository method surface plus the Riverpod providers that screens consume, since that boundary is what widget code and tests are written against (mirrors how `MutashabihatRepository`/`IndexRepo` already document Screens 1–4).

## `UserDataDatabaseHelper` (updated)

```dart
class UserDataDatabaseHelper {
  factory UserDataDatabaseHelper();                 // production singleton (unchanged, path_provider-backed)
  UserDataDatabaseHelper.withDatabase(Database db);  // NEW — test-only injection point

  Future<Database> get database;                     // unchanged signature
}
```

- `_dbVersion`: `1 → 2`.
- `_onCreate` (fresh installs): creates `favorites` (unchanged) **and** `ayah_notes`.
- `_onUpgrade(db, oldVersion, newVersion)` (NEW): if `oldVersion < 2`, create `ayah_notes` (idempotent `CREATE TABLE IF NOT EXISTS`, same DDL as in `_onCreate`).

## `UserDataRepository` (updated)

Constructor unchanged: `UserDataRepository({required UserDataDatabaseHelper databaseHelper})`. Tests build it as `UserDataRepository(databaseHelper: UserDataDatabaseHelper.withDatabase(inMemoryDb))`.

### Favorites (existing methods, unchanged — reused as-is)

`getFavorites()`, `getFavoritesBySurah(surahId)`, `isFavorite(surahId, ayahNum)`, `addFavorite(surahId, ayahNum, {note})`, `removeFavorite(surahId, ayahNum)`, `updateFavoriteNote(...)`, `getFavoriteCount()`, `clearAllFavorites()`.

> Note: `addFavorite`'s `{String? note}` param and `updateFavoriteNote` become **dead going forward** for this feature (notes now live in `ayah_notes`) but are left in place — not removed — since `FavoritesScreen`'s existing subtitle rendering (`favorite.note`) still reads them and removing them is out of scope for this spec.

### Ayah Notes (NEW)

```dart
/// Returns null if no note exists for (surahId, ayahNum).
Future<AyahNote?> getNote(int surahId, int ayahNum);

/// Insert-or-replace. Caller MUST have already validated
/// 1 <= noteText.trim().length <= 500 (repository does not re-validate
/// business rules — it persists exactly what's passed, matching the
/// existing repository layer's convention of doing raw persistence only).
Future<int> saveNote(int surahId, int ayahNum, String noteText);

/// No-op (returns 0) if no note exists.
Future<int> deleteNote(int surahId, int ayahNum);
```

Implementation notes:
- `saveNote` uses `db.insert('ayah_notes', {...}, conflictAlgorithm: ConflictAlgorithm.replace)`, setting `updated_at` to `DateTime.now().toIso8601String()` — same pattern as `addFavorite`.
- `getNote` uses `db.query('ayah_notes', where: 'surah_id = ? AND ayah_num = ?', whereArgs: [...], limit: 1)`, returns `null` when empty, else `AyahNote.fromMap(rows.first)`.

## Providers (`lib/src/core/providers/providers.dart`, additions)

```dart
/// The saved note for one ayah, or null if none exists.
/// Usage: ref.watch(noteProvider(AyahKey(surahId, ayahNum)))
final noteProvider = FutureProvider.family<AyahNote?, AyahKey>((ref, key) {
  final repo = ref.watch(userDataRepositoryProvider);
  return repo.getNote(key.surah, key.ayah);
});

/// Whether the mnemonic section should render. Wraps a compile-time flag
/// so a future settings screen can override it without UI rework (FR-014).
final mnemonicSectionEnabledProvider = Provider<bool>((ref) => kMnemonicSectionEnabled);
```

`favoritesProvider` and `isFavoriteProvider` are reused unchanged (already exist).

### Mutation contract (screen-level, no dedicated notifier class required)

The Ayah Detail screen performs mutations directly via `ref.read(userDataRepositoryProvider)` followed by `ref.invalidate(...)`, matching how `FavoritesScreen`'s existing `PopupMenuButton` TODOs were clearly intended to work and how simple the mutation surface is (single-row upsert/delete, no derived state to recompute):

| User action | Call | Then invalidate |
|---|---|---|
| Tap favorite (off → on) | `addFavorite(surahId, ayahNum)` | `isFavoriteProvider((surahId, ayahNum))`, `favoritesProvider` |
| Tap favorite (on → off) | `removeFavorite(surahId, ayahNum)` | same as above |
| Save note (add or edit), text valid | `saveNote(surahId, ayahNum, text.trim())` | `noteProvider(AyahKey(surahId, ayahNum))` |
| Confirm delete note | `deleteNote(surahId, ayahNum)` (only after `ConfirmDialog.show(...) == true`) | `noteProvider(AyahKey(surahId, ayahNum))` |

## `normalizeForSearch` (NEW, `lib/src/core/extensions/arabic_normalization.dart`)

```dart
/// Lower-cases, trims, and strips Arabic diacritics (tashkeel) so both a
/// user's query and stored surah names can be compared diacritic- and
/// case-insensitively via `String.contains`.
String normalizeForSearch(String input);
```

Pure function, no I/O, no Riverpod dependency — imported directly by `SurahsItemListView`'s filtering logic and unit-tested standalone.
