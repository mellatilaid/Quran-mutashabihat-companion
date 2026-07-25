# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter mobile app for exploring **Mutashabihat** — repeated or similar phrases across Quran verses. Users browse surahs, see which ayahs contain shared phrases, and compare those phrases across the full Quran with word-level highlighting.

## Commands

```bash
flutter pub get        # Install dependencies
flutter analyze        # Lint (flutter_lints)
flutter test           # Run tests
flutter run            # Launch on connected device/emulator
flutter build apk      # Android release build
flutter build ipa      # iOS release build
```

Run a single test file:
```bash
flutter test test/widget_test.dart
```

## Architecture

All app logic lives in `lib/files/`. The data flow is:

```
SQLite (assets/db/app.db)
  → DatabaseHelper (singleton, copies asset DB to writable path on first launch)
  → MutashabihatRepository (raw SQL queries, injectable DB for testing)
  → Riverpod Providers (FutureProvider / FutureProvider.family)
  → ConsumerWidget screens (ref.watch → .when for loading/error/data)
```

**Four screens** defined in `lib/files/example_usage.dart`, navigated via `Navigator.push()`:
1. `SurahIndexScreen` — lists all 114 surahs with mutashabihat ayah counts
2. `MutashabihatAyahsScreen` — lists ayahs in a surah that contain shared phrases
3. `AyahDetailScreen` — single ayah with word-level phrase highlights (amber chips)
4. `PhraseComparisonScreen` — all Quran-wide occurrences of a selected phrase

## Key Design Decisions

**Database is read-only.** `app.db` ships as a pre-built asset built externally by `import_mutashabihat.py` (not in repo). It is copied to `getApplicationDocumentsDirectory()` on first launch and never mutated by the app. Any user-generated data (future: favorites, mnemonic tips) must go in a separate writable database.

**Defensive clamping in repository.** Some phrase occurrence records have `word_to` values beyond the actual ayah length (e.g., phrase 4970 / ayah 48:10). `MutashabihatRepository` clamps these to valid bounds before returning data — do not remove this logic without checking the data.

**AyahKey composite key.** `FutureProvider.family` requires a single hashable parameter. The custom `AyahKey(surahId, ayahNum)` class in `mutashabihat_providers.dart` provides this for the `ayahDetailProvider`.

**Typography.** All text styles globally use the Amiri font (Google Fonts) for Arabic. The theme is configured in `lib/main.dart` with Material 3, green primary color (`#1B5E20`), and `Directionality(textDirection: TextDirection.rtl)` wrapping Arabic content.

## State Management

Riverpod 3 with `ConsumerWidget` + `ref.watch()`. Providers are in `lib/files/mutashabihat_providers.dart`:

- `mutashabihatRepositoryProvider` — shared `MutashabihatRepository` instance
- `surahsProvider` — all surahs for Screen 1
- `mutashabihatAyahsProvider(surahId)` — ayahs for Screen 2
- `ayahDetailProvider(AyahKey)` — word/highlight data for Screen 3
- `phraseProvider(phraseId)` — phrase metadata for Screen 4
- `phraseComparisonProvider(phraseId)` — all occurrences for Screen 4

## Untracked Experimental Code

`lib/revirpod_play_arround/` is a sandbox for Riverpod experiments and is not part of the main app. It is untracked by git.
