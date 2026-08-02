---
description: "Task list for Surah Search & Ayah Detail Enhancements"
---

# Tasks: Surah Search & Ayah Detail Enhancements

**Input**: Design documents from `/specs/001-ayah-favorites-notes/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/user-data-repository.md, quickstart.md

**Tests**: Explicitly requested by the spec (Clarifications session + FR-driven SC-006): unit tests for the data layer and diacritic-insensitive search, widget tests for the new/changed UI. Test tasks are included per user story.

**Organization**: Tasks are grouped by user story (US1–US4 from spec.md) to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Maps task to US1 (search), US2 (favorite), US3 (notes), US4 (layout)

## Path Conventions

Single Flutter mobile project. Source under `lib/src/`, tests under `test/`, matching plan.md's Project Structure section exactly.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the one new dependency required for real-SQLite unit testing (per research.md §4 / plan.md Testing).

- [ ] T001 Add `sqflite_common_ffi` as a `dev_dependencies` entry in `pubspec.yaml`, then run `flutter pub get`

**Checkpoint**: `sqflite_common_ffi` resolvable from `test/` — no other setup needed (no new routes, no new screens, no new top-level feature directory).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data-layer changes that Story 2 (reused as-is) and Story 3 (new) both need, plus the shared search primitive Story 1 needs. Must complete before any user-story phase below.

**⚠️ CRITICAL**: No user story implementation should begin until this phase is complete.

- [ ] T002 [P] Add `AyahNote` model (fromMap/toMap/copyWith, mirroring `FavoriteAyah`'s shape) to `lib/src/core/models/user_data_models.dart` per data-model.md
- [ ] T003 [P] Create `normalizeForSearch(String input)` pure function in `lib/src/core/extensions/arabic_normalization.dart`: strips Arabic diacritics/tashkeel (`ً-ٟ`, `ٰ`, `ۖ-ۭ` combining-mark ranges), lower-cases, trims — per research.md §1
- [ ] T004 In `lib/src/core/services/user_data_database_helper.dart`: bump `_dbVersion` from `1` to `2`; add `ayah_notes` table DDL (`id` PK AUTOINCREMENT, `surah_id` INTEGER NOT NULL, `ayah_num` INTEGER NOT NULL, `note_text` TEXT NOT NULL, `updated_at` TEXT NOT NULL, `UNIQUE(surah_id, ayah_num)`) plus `idx_ayah_notes_surah_id` index to `_onCreate`; add an `_onUpgrade(db, oldVersion, newVersion)` callback that creates `ayah_notes` (`CREATE TABLE IF NOT EXISTS`, same DDL) when `oldVersion < 2`, and wire it into `openDatabase(...)`
- [ ] T005 In `lib/src/core/services/user_data_database_helper.dart`: add `UserDataDatabaseHelper.withDatabase(Database db)` factory constructor (test-only injection point) alongside the existing production `factory UserDataDatabaseHelper()` singleton, per contracts/user-data-repository.md — the existing `database` getter must return the injected `db` directly when constructed this way, bypassing `path_provider`
- [ ] T006 In `lib/src/core/services/user_data_repository.dart`: add `getNote(int surahId, int ayahNum) -> Future<AyahNote?>`, `saveNote(int surahId, int ayahNum, String noteText) -> Future<int>` (insert-or-replace via `ConflictAlgorithm.replace`, setting `updated_at` to `DateTime.now().toIso8601String()`), and `deleteNote(int surahId, int ayahNum) -> Future<int>` (returns 0 if no row) — depends on T002, T004
- [ ] T007 Add `noteProvider = FutureProvider.family<AyahNote?, AyahKey>(...)` and `mnemonicSectionEnabledProvider = Provider<bool>((ref) => kMnemonicSectionEnabled)` to `lib/src/core/providers/providers.dart` — depends on T002, T006
- [ ] T008 [P] Create `lib/src/core/constants/feature_flags.dart` with `const bool kMnemonicSectionEnabled = false;` per research.md §6 — depends on T007's import

**Checkpoint**: `ayah_notes` table exists with a working migration path, `UserDataRepository` has full note CRUD, `normalizeForSearch` is available, and both new providers compile. User story phases can now begin.

---

## Phase 3: User Story 1 - Find a Surah quickly by searching (Priority: P1) 🎯 MVP

**Goal**: Live, diacritic-insensitive search field on the Surah Index screen that filters the in-memory 114-surah list as the user types, with an empty-state message and full-list restore on clear.

**Independent Test**: Open the Surah Index screen, type a partial surah name (Arabic or transliterated) into the search field, confirm the list narrows to matches; clear the field and confirm the full list returns; type a non-matching query and confirm the empty-state message appears.

### Tests for User Story 1

- [ ] T009 [P] [US1] Unit tests for `normalizeForSearch` in `test/core/extensions/arabic_normalization_test.dart`: diacritic stripping, case-insensitivity, trimming, substring matching examples (with and without tashkeel) — depends on T003

### Implementation for User Story 1

- [ ] T010 [US1] Add `searchQueryHint`, `searchNoResults`, and any other new-string keys to `lib/l10n/app_ar.arb`, then run `flutter gen-l10n`
- [ ] T011 [US1] Add a local `TextEditingController`-backed search field to `lib/src/features/index_tab/presentation/views/index_view.dart` (`SurahsItemListView` or equivalent) that filters the loaded `surahsProvider` list client-side via `normalizeForSearch`, matching against both `nameArabic` and `nameSimple`; render the localized empty-state message when no surah matches; restore the full list when the field is cleared — depends on T003, T010
- [ ] T012 [US1] Widget tests in `test/features/index_tab/presentation/index_view_test.dart`: typing a partial match narrows the list, an unmatched query shows the empty-state message, clearing the field restores all 114 items — depends on T011

**Checkpoint**: User Story 1 fully functional and testable independently of Stories 2–4.

---

## Phase 4: User Story 2 - Mark an ayah as favorite (Priority: P2)

**Goal**: Favorite toggle on the Ayah Detail screen that persists status in `user_data.db`, reflecting correctly across app restarts and re-navigation.

**Independent Test**: Open an ayah's detail screen, tap the favorite control, confirm it visually switches to "favorited" and persists across app restart, then tap again to unfavorite.

**Note**: `favorites` table, `UserDataRepository.addFavorite/removeFavorite/isFavorite`, and `favoritesProvider`/`isFavoriteProvider` already exist and are reused unchanged (research.md §2) — this story is UI-only wiring on top of Phase 2.

### Implementation for User Story 2

- [ ] T013 [US2] Add `favoriteAdded`/`favoriteRemoved` (if needed for a snackbar/confirmation) and any favorite-related label strings to `lib/l10n/app_ar.arb`, then run `flutter gen-l10n`
- [ ] T014 [US2] Add a favorite-toggle control to the header of `lib/src/features/index_tab/presentation/views/ayah_detail_screen.dart`, wired to `ref.watch(isFavoriteProvider((surahId, ayahNum)))` for display state and `ref.read(userDataRepositoryProvider).addFavorite(...)`/`removeFavorite(...)` on tap, followed by `ref.invalidate(isFavoriteProvider((surahId, ayahNum)))` and `ref.invalidate(favoritesProvider)` — depends on T013

### Tests for User Story 2

- [ ] T015 [US2] Widget tests in `test/features/index_tab/presentation/ayah_detail_screen_test.dart`: favorite control renders "not favorited" state, tapping toggles to "favorited" and calls `addFavorite`, tapping again calls `removeFavorite` and reverts state — depends on T014

**Checkpoint**: User Stories 1 AND 2 both work independently.

---

## Phase 5: User Story 3 - Add, edit, and remove a personal note on an ayah (Priority: P2)

**Goal**: Multi-line note editor on the Ayah Detail screen backed by the new `ayah_notes` table: add, edit, delete-with-confirmation, 500-char cap with counter, empty/whitespace rejection.

**Independent Test**: Open an ayah with no note, add note text, leave and reopen the same ayah to confirm persistence, edit the note, then delete it (with confirmation) to confirm it no longer appears.

### Tests for User Story 3

- [ ] T016 [P] [US3] Unit tests in `test/core/services/user_data_repository_test.dart` (built against an in-memory `sqflite_common_ffi` database via `UserDataDatabaseHelper.withDatabase(...)`): `getNote` returns null when absent, `saveNote` inserts then upserts (replace) on a second call for the same surah+ayah, `deleteNote` removes the row and returns 0 when called again on an already-deleted note, and (as regression coverage) existing `favorites` methods still work against the same injected database — depends on T005, T006, T001

### Implementation for User Story 3

- [ ] T017 [US3] Add note-related strings (add/edit/save/delete labels, empty-state placeholder, delete-confirmation prompt text, character-counter format) to `lib/l10n/app_ar.arb`, then run `flutter gen-l10n`
- [ ] T018 [US3] Add a note section widget to `lib/src/features/index_tab/presentation/views/ayah_detail_screen.dart`: renders empty "add note" state via `ref.watch(noteProvider(AyahKey(surahId, ayahNum)))` when null, else displays the saved note text with edit/delete controls; edit mode uses a multi-line expanding `TextField`/`TextFormField` (`maxLines: null`, `maxLength: 500`) with a character counter as the limit approaches; rejects save when `text.trim().isEmpty` or `text.trim().length > 500` — depends on T007, T017
- [ ] T019 [US3] Wire note save to `ref.read(userDataRepositoryProvider).saveNote(surahId, ayahNum, text.trim())` then `ref.invalidate(noteProvider(AyahKey(surahId, ayahNum)))`; wire delete to show the existing `ConfirmDialog` (`lib/src/core/widgets/confirm_dialog.dart`) first, and only on confirm call `deleteNote(surahId, ayahNum)` then invalidate the same provider; declining the dialog leaves the note unchanged — depends on T018

### Tests continued

- [ ] T020 [US3] Widget tests appended to `test/features/index_tab/presentation/ayah_detail_screen_test.dart`: empty-note state renders "add note" affordance, entering text and confirming shows the saved note, editing replaces the text, tapping delete shows a confirmation dialog, declining leaves the note intact, confirming clears it back to the empty state, and an empty/whitespace-only save attempt is rejected without persisting — depends on T019

**Checkpoint**: User Stories 1, 2, AND 3 all work independently.

---

## Phase 6: User Story 4 - Redesigned ayah detail layout (Priority: P3)

**Goal**: Restructure the Ayah Detail screen into: header (surah:ayah ref + favorite toggle) → ayah text card → similar-phrases list (color marker + occurrence count per phrase, tap-to-isolate preserved) → mnemonic section (flag-gated, hidden by default) → note section.

**Independent Test**: Open an ayah with two or more shared phrases, confirm the layout order and that each phrase entry shows a distinguishing color marker plus its total Quran-wide occurrence count; tap a phrase entry and confirm only that phrase highlights in the ayah text; confirm the mnemonic section is absent while disabled; open an ayah with zero shared phrases and confirm the similar-phrases section is omitted/shows an empty state instead of an empty list.

**Depends on**: Phase 4 (favorite toggle) and Phase 5 (note section) being present as the elements this layout hosts, per plan.md's stated sequencing.

### Implementation for User Story 4

- [x] T021 [US4] Define the fixed 3-color cycling phrase-marker palette using the existing `AppColors.lightTeal/lightGold/lightRose` (and dark equivalents `darkTeal/darkGold/darkRose`) in `lib/src/features/index_tab/presentation/views/ayah_detail_screen.dart`, assigned by `ayahDetail.phraseIds` list index `% 3`, theme-aware via `Theme.of(context).brightness` — per research.md §5
- [x] T022 [US4] Reuse `PillBadge` (`lib/src/core/widgets/pill_badge.dart`) to render each similar-phrase list entry with its assigned color marker and occurrence count sourced from `ref.watch(phraseProvider(phraseId)).occurrenceCount` (one watch per `phraseId` in `ayahDetail.phraseIds`) — depends on T021
- [x] T023 [US4] Restructure `lib/src/features/index_tab/presentation/views/ayah_detail_screen.dart`'s build order to: header (ref + favorite toggle from T014) → ayah text card → similar-phrases list from T022, showing an empty-state placeholder instead of an empty list when `phraseIds` is empty → mnemonic section placeholder gated behind `ref.watch(mnemonicSectionEnabledProvider)` (renders nothing while `false`) → note section from T018/T019 — depends on T014, T018, T019, T022
- [x] T024 [US4] Verify/preserve existing tap-to-isolate behavior: tapping a phrase entry in the restructured list highlights only that phrase's words in the ayah text above (reuse existing selected-phrase state/logic, relocated not rewritten) — depends on T023

### Tests for User Story 4

- [x] T025 [US4] Widget tests appended to `test/features/index_tab/presentation/ayah_detail_screen_test.dart`: layout renders in order (header, ayah card, phrase list, note section) for an ayah with shared phrases, each phrase entry shows a color marker and occurrence count, tapping a phrase entry isolates its highlight, the mnemonic section is absent while `kMnemonicSectionEnabled` is `false`, and an ayah with zero shared phrases shows the empty-state instead of an empty list — depends on T024

**Checkpoint**: All four user stories are independently functional and the full redesigned screen matches the reference layout.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final validation across all stories.

- [x] T026 Run `flutter analyze` and fix any reported issues across all touched files
- [x] T027 Run `flutter test` (full suite) and confirm all unit and widget tests pass
- [x] T028 Execute the manual validation steps in `specs/001-ayah-favorites-notes/quickstart.md` for all four user stories plus the SC-005 regression check (existing word highlighting and phrase-comparison navigation unchanged), including dark-mode/light-mode and RTL checks

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup (T001 needed before T016's test infra, though T002–T008 themselves don't need T001) — BLOCKS all user stories.
- **User Story 1 (Phase 3)**: Depends on Foundational T003 only; independent of Stories 2–4.
- **User Story 2 (Phase 4)**: Depends on Foundational completion (uses pre-existing favorites plumbing); independent of Stories 1, 3, 4 at the data layer, but Phase 6 later relocates its UI.
- **User Story 3 (Phase 5)**: Depends on Foundational T002, T004–T007 (new `ayah_notes` table/repo/provider); independent of Stories 1, 2 at the data layer, but Phase 6 later relocates its UI.
- **User Story 4 (Phase 6)**: Depends on Phases 4 and 5 (hosts the favorite toggle and note section within the new layout) — sequenced last per plan.md.
- **Polish (Phase 7)**: Depends on all four user stories being complete.

### Within Each User Story

- Tests before or alongside implementation per task ordering above (T009 before T011; T016 before/alongside T017–T019; T020/T025 after their implementation tasks since they exercise the finished widget).
- Repository/provider layer before UI wiring.
- Story complete and checkpointed before the next priority phase starts.

### Parallel Opportunities

- T002 and T003 (Phase 2) can run in parallel — different files, no shared dependency.
- T008 can run in parallel with T002/T003 (different file), though T007 must wait on T002.
- T009 (US1 test) can be written in parallel with Phase 2's T004–T008 since it only depends on T003.
- T016 (US3 repository unit tests) can be developed in parallel with Phase 4 (US2) work once Phase 2 is complete, since they touch disjoint files.
- Phases 4 and 5 (US2 and US3) can be implemented in parallel by different developers once Phase 2 is done — both touch `ayah_detail_screen.dart` but in additive, non-overlapping sections (header vs. note section) until Phase 6 merges the layout.

---

## Parallel Example: Phase 2 (Foundational)

```bash
# Launch independent foundational tasks together:
Task: "Add AyahNote model to lib/src/core/models/user_data_models.dart"
Task: "Create normalizeForSearch in lib/src/core/extensions/arabic_normalization.dart"
Task: "Create lib/src/core/constants/feature_flags.dart with kMnemonicSectionEnabled"
```

## Parallel Example: User Story 1

```bash
# Test and implementation for US1 (test can start once T003 lands):
Task: "Unit tests for normalizeForSearch in test/core/extensions/arabic_normalization_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001).
2. Complete Phase 2: Foundational (T002–T008) — required even for US1 alone, since T003 (`normalizeForSearch`) lives there.
3. Complete Phase 3: User Story 1 (T009–T012).
4. **STOP and VALIDATE**: Run the quickstart.md US1 manual steps independently.
5. Demo the search field as the MVP increment.

### Incremental Delivery

1. Setup + Foundational → foundation ready (search primitive, notes table/repo/provider, favorites reused).
2. Add User Story 1 → test independently → demo (MVP).
3. Add User Story 2 → test independently → demo.
4. Add User Story 3 → test independently → demo.
5. Add User Story 4 (redesign, hosts US2+US3 UI) → test independently → demo full reference layout.
6. Phase 7 polish → `flutter analyze` clean, full `flutter test` pass, full quickstart.md walkthrough.

### Parallel Team Strategy

With multiple developers, after Phase 2 completes:

- Developer A: User Story 1 (search) — fully isolated to `index_view.dart` + `arabic_normalization.dart`.
- Developer B: User Story 2 (favorite toggle) — header section of `ayah_detail_screen.dart`.
- Developer C: User Story 3 (notes) — note section of `ayah_detail_screen.dart` + repository methods.
- One developer picks up User Story 4 once B and C land, to merge both sections into the final layout order and add the phrase-list/mnemonic restructuring.

---

## Notes

- [P] tasks touch different files with no unmet dependencies.
- [Story] labels map every implementation/test task to US1–US4 for traceability back to spec.md.
- `favorites` table and its repository methods are reused unchanged (research.md §2) — no migration or model task needed for Favorite itself, only new UI wiring (Phase 4).
- `ayah_notes` is a new, independent table — deliberately not a foreign key off `favorites` (data-model.md, research.md §3).
- Verify new/changed widget and unit tests fail before their corresponding implementation task, per constitution Principle II.
- Commit after each task or logical group.
- Avoid: vague tasks, same-file conflicts within a single phase, cross-story dependencies that break independent testability (only Phase 6 intentionally depends on Phases 4–5, as documented above).
