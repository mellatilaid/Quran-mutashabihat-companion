# Implementation Plan: Surah Search & Ayah Detail Enhancements

**Branch**: `001-ayah-favorites-notes` | **Date**: 2026-08-02 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-ayah-favorites-notes/spec.md`

## Summary

Add a live, diacritic-insensitive search field to the Surah Index screen, and redesign the Ayah Detail screen to add a favorite toggle, a persistent free-text note (add/edit/delete with confirm), and a restructured "similar phrases" list with per-phrase color markers and occurrence counts, while keeping the mnemonic section present but hidden behind a single feature flag.

Most of the persistence plumbing already exists ahead of this spec: `favorites` table/repository/providers (`favoritesProvider`, `isFavoriteProvider`, `UserDataRepository.addFavorite/removeFavorite`) are already implemented and will be reused as-is for Story 2. Story 3 (notes) needs a **new, independent** `ayah_notes` table because the current `favorites.note` column couples a note to being favorited, which contradicts the spec's Key Entities (a note must be addable/removable independent of favorite status). Story 1 (search) and Story 4 (layout) are net-new UI work built on existing providers.

## Technical Context

**Language/Version**: Dart (SDK `^3.12.0`), Flutter stable

**Primary Dependencies**: `flutter_riverpod` 3.x, `go_router` 14.x, `sqflite` 2.4.x, `path_provider`, `google_fonts`, `intl`/`flutter_localizations`

**Storage**: Two local SQLite databases via `sqflite`: read-only `app.db` (bundled asset, unchanged) and writable `user_data.db` (`UserDataDatabaseHelper`) — this feature adds a new `ayah_notes` table to `user_data.db` via a `_dbVersion` bump + `onUpgrade`, and reuses the existing `favorites` table unchanged.

**Testing**: `flutter_test` (widget tests) + `test` package (unit tests). `sqflite` cannot run on the plain Dart VM used by `flutter test` for repository unit tests, so `sqflite_common_ffi` is added as a dev dependency to back `UserDataRepository`/`ayah_notes` unit tests with a real in-memory SQLite engine, matching how `MutashabihatRepository` is already tested with an injectable `Database`.

**Target Platform**: Android + iOS (Flutter mobile app)

**Project Type**: Mobile app — single Flutter project, feature-first under `lib/src/features/`

**Performance Goals**: Search filtering must feel instant (<16ms per keystroke) against the in-memory 114-item surah list already held by `surahsProvider` — no new DB query per keystroke. Favorite/note reads/writes are single-row indexed SQLite operations (<50ms typical on-device).

**Constraints**: Offline-only, no backend/auth. Must not mutate `app.db`. All new interactive UI must have RTL Arabic support, light/dark theming, and localized strings per Principle III.

**Scale/Scope**: 114 surahs (in-memory filter), 1 favorite + at most 1 note per ayah, small fixed color palette (reuse existing `AppColors` teal/gold/rose tokens) for phrase markers.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Code Quality & Architecture Discipline** — PASS. New code follows SQLite → repository → Riverpod provider → `ConsumerWidget` → GoRouter. No screen will query SQLite directly. `app.db` stays untouched; new writable data goes into `user_data.db`'s new `ayah_notes` table, consistent with the existing `favorites` table. The `word_to` clamping logic in `MutashabihatRepository`/`IndexRepo` is untouched.
- **II. Testing Standards (NON-NEGOTIABLE)** — PASS, with one required fix identified in Phase 0: `UserDataDatabaseHelper` currently hardcodes its own singleton `Database` with no injection point, which violates "production code MUST NOT hardcode the singleton ... in a way that prevents test injection." This plan adds an injectable-`Database` constructor path (mirroring `IndexRepo`/`MutashabihatRepository`) as a prerequisite for the new unit tests. Unit tests will cover: diacritic-insensitive search matching, the new `ayah_notes` repository methods (add/edit/delete/empty-note rejection/500-char enforcement), and phrase-color-assignment determinism. Widget tests will cover: the search field (filter + empty state + clear), the favorite toggle (both states), the note editor (empty/filled/confirm-delete/cancel), and the redesigned Ayah Detail screen's loading/error/data branches.
- **III. User Experience Consistency** — PASS. All new strings go into `app_ar.arb`/`AppLocalizations`. New widgets reuse `ArabicLine`, `PillBadge`, `ConfirmDialog`, `CustomAppBar`, `CustomLoadingWidget`/`CustomErrorWidget`, and theme tokens from `AppColors`/`app_theme.dart` rather than introducing new ad-hoc colors. Navigation stays within the existing GoRouter tree (no new routes needed — search and notes are in-place state on existing screens).
- **IV. Performance Requirements** — PASS. Surah search filters the already-cached `surahsProvider` list client-side (no new query per keystroke) and the list stays on `ListView.builder`. Favorite/note providers are scoped `.family` reads keyed by `(surahId, ayahNum)` so unrelated widgets don't rebuild.

**Result**: No violations requiring the Complexity Tracking table.

## Project Structure

### Documentation (this feature)

```text
specs/001-ayah-favorites-notes/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output
├── data-model.md         # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/            # Phase 1 output
│   └── user-data-repository.md
└── tasks.md             # Phase 2 output (/speckit-tasks — not created here)
```

### Source Code (repository root)

```text
lib/src/
├── core/
│   ├── extensions/
│   │   └── arabic_normalization.dart        # NEW — diacritic stripping + normalize-for-search
│   ├── constants/
│   │   └── app_colors.dart                  # existing — reused for the fixed phrase-marker palette
│   ├── models/
│   │   └── user_data_models.dart            # UPDATED — add AyahNote model alongside FavoriteAyah
│   ├── services/
│   │   ├── user_data_database_helper.dart   # UPDATED — injectable Database, version 2, ayah_notes table
│   │   └── user_data_repository.dart        # UPDATED — add/get/update/delete ayah_notes methods
│   ├── providers/
│   │   └── providers.dart                   # UPDATED — noteProvider(AyahKey), note controller
│   └── widgets/
│       ├── confirm_dialog.dart               # existing — reused for delete-note confirmation
│       └── pill_badge.dart                   # existing — reused for phrase color markers
├── features/
│   └── index_tab/
│       └── presentation/
│           └── views/
│               ├── index_view.dart           # UPDATED — search field + filtered list + empty state
│               └── ayah_detail_screen.dart   # UPDATED — redesigned layout: header, favorite toggle,
│                                              #   ayah card, colored phrase list w/ counts, mnemonic
│                                              #   placeholder (flag-gated), note section
lib/l10n/app_ar.arb                           # UPDATED — new search/favorite/note strings

test/
├── core/
│   ├── extensions/
│   │   └── arabic_normalization_test.dart    # NEW — unit tests for diacritic-insensitive matching
│   └── services/
│       └── user_data_repository_test.dart    # NEW — unit tests for ayah_notes CRUD + favorites reuse
└── features/
    └── index_tab/
        └── presentation/
            ├── index_view_test.dart          # NEW — widget tests for search
            └── ayah_detail_screen_test.dart  # NEW — widget tests for favorite/note/phrase list
```

**Structure Decision**: Single Flutter mobile app, feature-first (`lib/src/features/<feature>/{presentation,domain,data}` plus shared `lib/src/core/`), matching the existing repo layout. No new feature directory is needed — search lives in the existing `index_tab` feature, and favorites/notes persistence lives in the existing shared `core/services` + `core/providers` layer alongside the already-scaffolded `favorites_tab`.

## Complexity Tracking

*No Constitution Check violations — table intentionally omitted.*
