# Phase 0 Research: Surah Search & Ayah Detail Enhancements

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the spec's own Clarifications session already resolved the open product questions (diacritic handling, delete confirmation, note length/multi-line, phrase color assignment, test scope). The research below covers the remaining *implementation* decisions needed to execute the plan against the current codebase.

## 1. Diacritic-insensitive, case-insensitive substring search for surah names

- **Decision**: Add a pure function `String normalizeForSearch(String input)` in `lib/src/core/extensions/arabic_normalization.dart` that (a) removes Arabic diacritics/tashkeel via a regex over the Unicode combining-mark range used in Quranic Arabic (`ً-ٟ`, `ٰ`, `ۖ-ۭ`), (b) lower-cases the result (for the Latin `nameSimple` field), and (c) trims. `SurahsItemListView`'s search filters `surahs.where((s) => normalizeForSearch(s.nameArabic).contains(q) || normalizeForSearch(s.nameSimple).contains(q))` where `q = normalizeForSearch(query)`.
- **Rationale**: The full surah list (114 rows) is already fully loaded in memory via `surahsProvider` (`FutureProvider<List<Surah>>`), so filtering client-side with a `StateProvider<String>`/local `TextEditingController` avoids any new SQL query per keystroke (Principle IV) and keeps `IndexRepo`/`MutashabihatRepository` untouched. A pure, dependency-free normalization function is trivially unit-testable without a widget harness.
- **Alternatives considered**: SQL `LIKE` with `COLLATE NOCASE` against `app.db` — rejected because SQLite's default collation doesn't strip Arabic diacritics, would require a new query per keystroke, and the dataset is small enough that in-memory filtering is strictly simpler and faster.

## 2. Favorites persistence

- **Decision**: Reuse the existing `favorites` table, `UserDataRepository.addFavorite/removeFavorite/isFavorite`, and `favoritesProvider`/`isFavoriteProvider` in `lib/src/core/providers/providers.dart` unchanged. The Ayah Detail screen's new favorite toggle calls `ref.read(userDataRepositoryProvider).addFavorite(surahId, ayahNum)` / `removeFavorite(...)` then invalidates `isFavoriteProvider((surahId, ayahNum))` and `favoritesProvider`.
- **Rationale**: This plumbing already exists, already matches FR-006–FR-008 and FR-017 (separate writable store, survives restart, keyed by surah+ayah), and is already consumed by the scaffolded `FavoritesScreen`. Re-implementing it would violate the "don't introduce speculative abstractions" guidance.
- **Alternatives considered**: None — existing code already satisfies the requirement.

## 3. Notes persistence (new, independent of favorites)

- **Decision**: Add a new `ayah_notes` table to `user_data.db` (surah_id, ayah_num, note_text, updated_at, `UNIQUE(surah_id, ayah_num)`), reached via new `UserDataRepository` methods (`getNote`, `saveNote` — upsert via `ConflictAlgorithm.replace`, `deleteNote`). `UserDataDatabaseHelper._dbVersion` bumps 1 → 2 with an `onUpgrade` that creates the table for existing installs (mirroring `onCreate` for fresh installs).
- **Rationale**: The spec's Key Entities section models `Favorite` and `Ayah Note` as independent entities ("At most one note exists per ayah at a time" with no mention of requiring favorite status), and Edge Cases require identical state "regardless of navigation path" keyed by surah+ayah — nothing ties a note's existence to favorite status. The existing `favorites.note` column would force "must favorite to note," which is a behavior change not requested and contradicted by Story 3's acceptance scenarios (they never favorite the ayah). The `favorites.note` column is left in place (untouched, unused going forward) rather than dropped, since `sqflite`'s bundled SQLite has limited `ALTER TABLE DROP COLUMN` support and removing it isn't required for correctness.
- **Alternatives considered**: Storing notes as a JSON blob in `SharedPreferences` — rejected because the app has no `shared_preferences` dependency yet, `sqflite` is already the established writable-storage pattern (`UserDataDatabaseHelper`), and SQLite gives free indexed lookup by `(surah_id, ayah_num)` consistent with `favorites`.

## 4. Testability of `UserDataDatabaseHelper` (constitution gap)

- **Decision**: Add an optional `Database? database` constructor parameter to `UserDataRepository` (already present) and change `UserDataDatabaseHelper` to accept an optional injected `Database` too, OR — simpler — have `UserDataRepository`'s tests construct a fake `UserDataDatabaseHelper`-shaped object. Concretely: give `UserDataDatabaseHelper` a factory constructor variant (or a `static Future<Database> openForTesting()` using `sqflite_common_ffi`'s `databaseFactoryFfi.openDatabase(inMemoryDatabasePath, ...)` reusing the same `_onCreate`/`onUpgrade` schema) and have `UserDataRepository` accept that `Database` directly via its existing `database` parameter path — i.e. refactor `UserDataRepository` to optionally take a `Database` directly instead of only a `UserDataDatabaseHelper`, matching the `IndexRepo({Database? database})` pattern already used for `app.db`.
- **Rationale**: Constitution Principle II requires repository/provider logic be testable against an injected database instance; `UserDataDatabaseHelper` currently is a hard singleton with a `path_provider`-backed path, unusable from `flutter test`'s Dart-VM environment. `sqflite_common_ffi` is the standard way to run real SQLite (not a mock) under `flutter test`/`dart test` for exactly this scenario.
- **Alternatives considered**: Mocking the repository entirely (no real SQL) — rejected; the constitution explicitly favors testing against a real (in-memory/fixture) database over mocks, and this is the same pattern already used for `MutashabihatRepository`.

## 5. Phrase-marker color palette

- **Decision**: Define a small fixed `List<Color>` (light/dark variants) in `AppColors` — reuse the existing `teal`/`gold`/`rose` triplet already defined (`lightTeal/lightGold/lightRose` and dark equivalents) as the 3-color cycling palette, assigned by `ayahDetail.phraseIds` list index `% 3`, matching FR-015's "fixed palette cycling by position."
- **Rationale**: `AppColors` already defines exactly three theme-aware accent colors used elsewhere in the app (favorites' rose icon, danger, etc.), so reusing them keeps the new phrase markers visually consistent with the rest of the UI (Principle III) instead of introducing a fourth ad-hoc palette.
- **Alternatives considered**: A larger bespoke palette (5–8 colors) — rejected as unnecessary; ayahs in this dataset rarely contain more than 2–3 distinct shared phrases, and the palette is explicitly allowed to wrap per FR-015.

## 6. Mnemonic section feature flag

- **Decision**: A single `const bool kMnemonicSectionEnabled = false;` constant in a new small `lib/src/core/constants/feature_flags.dart`, exposed to widgets via a trivial `Provider<bool>((ref) => kMnemonicSectionEnabled)` in `providers.dart` so the redesigned `AyahDetailScreen` reads it through `ref.watch()` like any other setting, without hardcoding the constant inline in the widget.
- **Rationale**: FR-014 only requires "a single configurable setting" with no runtime toggle UI specified (mnemonic content/authoring is explicitly out of scope). Wrapping the constant in a `Provider<bool>` costs nothing extra now but means a future settings screen can override the flag later "without further UI rework," which is the requirement's explicit intent.
- **Alternatives considered**: Reading the `const bool` directly in the widget with no provider — rejected only because it would need an edit to the widget itself the day this becomes user-toggleable, which is the exact rework FR-014 asks to avoid.
