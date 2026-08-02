# Quickstart: Validating Surah Search & Ayah Detail Enhancements

## Prerequisites

```bash
flutter pub get
flutter gen-l10n          # after adding new strings to lib/l10n/app_ar.arb
```

If a device/emulator is already running the app with a pre-existing `user_data.db` (version 1), the `_onUpgrade` migration (see [contracts/user-data-repository.md](./contracts/user-data-repository.md)) must run automatically on next launch — no manual reset required. To force a clean-slate check, uninstall the app from the device/emulator first.

## Automated checks (run before manual validation)

```bash
flutter analyze                                   # MUST report zero issues
flutter test                                       # unit + widget tests, MUST pass in full
flutter test test/core/extensions/arabic_normalization_test.dart
flutter test test/core/services/user_data_repository_test.dart
flutter test test/features/index_tab/presentation/index_view_test.dart
flutter test test/features/index_tab/presentation/ayah_detail_screen_test.dart
```

## Manual validation — User Story 1: Surah search (P1)

```bash
flutter run
```

1. Open the app (Index tab, `/`) — confirm all 114 surahs are listed.
2. Type a partial Arabic surah name (e.g. part of `البقرة`) into the new search field → list narrows to matching surah(s).
3. Type the same query without any tashkeel marks, and separately a query that includes tashkeel not present in the stored name → confirm both match identically (diacritic-insensitive, FR-003).
4. Type text matching no surah → confirm the empty-state message appears instead of a blank list (FR-004).
5. Clear the field → confirm the full 114-surah list returns (FR-005).

## Manual validation — User Story 2: Favorite an ayah (P2)

1. Navigate to any ayah's detail screen (`/surah/:id/ayah/:surahId/:ayahNum`).
2. Tap the favorite toggle in the header → confirm it visually switches to "favorited" immediately.
3. Fully close and relaunch the app, reopen the same ayah → confirm it still shows as favorited (FR-007, FR-008, SC-002).
4. Tap again to unfavorite → confirm it reverts and the change persists across a relaunch.

## Manual validation — User Story 3: Add/edit/remove a note (P2)

1. Open an ayah with no saved note → confirm the note section shows its empty/"add note" state.
2. Enter text and confirm → note is saved and displayed (FR-009, FR-010).
3. Leave and reopen the same ayah (or relaunch the app) → confirm the note text is still shown automatically.
4. Edit the note text and confirm → confirm the updated text persists on next visit (FR-011).
5. Attempt to save an empty/whitespace-only note → confirm it is rejected and no note is persisted (FR-013).
6. Type past 500 characters → confirm input is capped and a counter appears as the limit approaches (FR-013a).
7. Confirm the input is a multi-line expanding field, not single-line (FR-013b).
8. Tap remove → confirm a confirmation prompt appears; decline it → confirm the note is unchanged (FR-012).
9. Tap remove again and confirm → confirm the note is deleted and the section returns to its empty state.

## Manual validation — User Story 4: Redesigned ayah detail layout (P3)

1. Open an ayah with two or more shared phrases → confirm layout order: header (surah:ayah ref + favorite toggle) → ayah text card → similar-phrases list (each entry shows a distinct color marker, from the fixed palette, plus its total Quran-wide occurrence count) → mnemonic section (should be absent, per the disabled flag) → note section.
2. Tap one phrase entry → confirm only that phrase's words are highlighted in the ayah text above (existing tap-to-isolate behavior preserved, FR-016).
3. Open an ayah with zero shared phrases → confirm the similar-phrases section is omitted or shows an appropriate empty state, not an empty list (Edge Cases).
4. Toggle dark mode → confirm the whole screen (search field, favorite icon, phrase markers, note section) respects `lightTheme`/`darkTheme` with no hardcoded colors that break dark mode.

## Regression check (SC-005)

Confirm existing Ayah Detail behavior is unchanged: word-level phrase highlighting still renders correctly, and the "compare phrase" navigation to `/surah/:id/ayah/:surahId/:ayahNum/phrase/:phraseId` still works from the redesigned phrase list.
