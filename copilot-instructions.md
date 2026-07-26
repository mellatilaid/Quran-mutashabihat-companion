# Copilot Instructions for Quran Mutashabihat App

This file provides persistent guidance to AI assistants when working with this Flutter project.

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
flutter gen-l10n       # Generate localization files
```

Run a single test file:
```bash
flutter test test/widget_test.dart
```

## Project Structure

```
lib/
├── l10n/                          # Localization files
│   └── app_ar.arb                 # Arabic strings (key-value pairs)
├── src/
│   ├── core/                      # Shared utilities, constants, and helpers
│   │   ├── constants/
│   │   ├── extensions/
│   │   ├── helpers/
│   │   ├── services/
│   │   ├── theme/
│   │   │   └── app_theme.dart     # Light & dark theme definitions
│   │   ├── widgets/               # Reusable UI components
│   │   ├── router.dart            # GoRouter configuration
│   │   └── providers.dart         # Global Riverpod providers
│   ├── features/                  # Feature-specific code (organized by feature)
│   │   ├── surah_index/
│   │   │   ├── presentation/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── mutashabihat_ayahs/
│   │   ├── ayah_detail/
│   │   └── phrase_comparison/
│   ├── main.dart                  # App entry point with MaterialApp setup
│   └── app.dart                   # App widget with GoRouter configuration
```

## Architecture

The app follows **feature-first architecture** with clean separation of concerns:

```
SQLite (assets/db/app.db)
  → DatabaseHelper (singleton, copies asset DB to writable path on first launch)
  → MutashabihatRepository (raw SQL queries, injectable DB for testing)
  → Riverpod Providers (FutureProvider / FutureProvider.family)
  → ConsumerWidget screens (ref.watch → .when for loading/error/data)
  → GoRouter navigation
```

**Four main features** with dedicated screens:

1. **Surah Index Screen** — lists all 114 surahs with mutashabihat ayah counts
2. **Mutashabihat Ayahs Screen** — lists ayahs in a surah that contain shared phrases
3. **Ayah Detail Screen** — single ayah with word-level phrase highlights (amber chips)
4. **Phrase Comparison Screen** — all Quran-wide occurrences of a selected phrase

## Key Design Decisions

**Database is read-only.** `app.db` ships as a pre-built asset built externally. It is copied to `getApplicationDocumentsDirectory()` on first launch and never mutated by the app. Any user-generated data must go in a separate writable database.

**Defensive clamping in repository.** Some phrase occurrence records have `word_to` values beyond the actual ayah length. `MutashabihatRepository` clamps these to valid bounds before returning data — do not remove this logic without checking the data.

**AyahKey composite key.** `FutureProvider.family` requires a single hashable parameter. The custom `AyahKey(surahId, ayahNum)` class in `lib/src/core/providers.dart` provides this for the `ayahDetailProvider`.

**Typography.** All text styles use the Amiri font (Google Fonts) for Arabic. The theme uses Material 3, green primary color (`#1B5E20`), and `Directionality(textDirection: TextDirection.rtl)` wrapping Arabic content.

## State Management

**Riverpod 3** with `ConsumerWidget` + `ref.watch()`. Providers are in `lib/src/core/providers.dart`:

- `mutashabihatRepositoryProvider` — shared `MutashabihatRepository` instance
- `surahsProvider` — all surahs for Screen 1
- `mutashabihatAyahsProvider(surahId)` — ayahs for Screen 2
- `ayahDetailProvider(AyahKey)` — word/highlight data for Screen 3
- `phraseProvider(phraseId)` — phrase metadata for Screen 4
- `phraseComparisonProvider(phraseId)` — all occurrences for Screen 4

**Always use `ConsumerWidget` for screens.** Wrap `ref.watch()` calls at the top of the build method. Lift providers into widget parameters only when reusing the same component with different providers.

## Routing with GoRouter

All screen navigation uses **GoRouter** (defined in `lib/src/core/router.dart`). Routes:

- `'/'` — `SurahIndexScreen`
- `'/surah/:id'` — `MutashabihatAyahsScreen`
- `'/ayah/:surahId/:ayahNum'` — `AyahDetailScreen`
- `'/phrase/:phraseId'` — `PhraseComparisonScreen`

Access via:
```dart
context.go('/surah/1')
context.goNamed('surahDetail', pathParameters: {'id': '1'})
```

## Custom Widgets Architecture

Reusable UI components live in `lib/src/core/widgets/` and follow a consistent pattern:

- **Stateless components** (no local state):
  - `AyahCard` — displays a single ayah with phrase highlights
  - `PhraseHighlight` — amber chip for phrase occurrences
  - `SurahListTile` — surah name + ayah count
  - `WordList` — renders words with selected word highlighting

- **Consumer components** (state via Riverpod):
  - `AyahDetailView` — uses `ayahDetailProvider` to display full ayah + word breakdown
  - `PhraseComparisonList` — uses `phraseComparisonProvider` to show all occurrences

## Theme Management (Dark & Light)

Theme configuration in `lib/src/core/theme/app_theme.dart` exports two themes.

Colors:
- Primary (light): `Color(0xFF1B5E20)` (dark green)
- Primary (dark): `Color(0xFF66BB6A)` (light green)
- Light background: `Color(0xFFFAFAFA)`
- Dark background: `Color(0xFF121212)`

**Runtime theme switching via Riverpod:**
```dart
final themeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark
```

Apply in `MaterialApp`:
```dart
themeMode: ref.watch(themeProvider) ? ThemeMode.dark : ThemeMode.light,
```

## Localization (Arabic)

Localization uses **flutter_localizations** and **intl**.

### Files
- `lib/l10n/app_ar.arb` — Arabic strings (key-value pairs)
- `lib/generated/l10n/app_localizations.dart` — auto-generated
- `lib/generated/l10n/app_localizations_ar.dart` — Arabic impl

### pubspec.yaml Configuration
```yaml
flutter:
  generate: true

flutter_gen:
  outputs_dir: lib/generated
  line_length: 80
```

### Usage
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final l10n = AppLocalizations.of(context)!;
return Text(l10n.surahListTitle); // e.g., "قائمة السور"
```

### Adding New Strings
1. Add to `lib/l10n/app_ar.arb`:
   ```json
   "newString": "النص العربي"
   ```
2. Run: `flutter gen-l10n`
3. Use: `AppLocalizations.of(context)!.newString`

**Only Arabic (`ar`) is supported for now.** To add more languages, create `app_en.arb`, `app_fr.arb`, etc., and update `supportedLocales` in `lib/src/main.dart`.

## Implementation Guidelines

### When Creating New Features
1. Create feature folder under `lib/src/features/<feature_name>/`
2. Organize as `presentation/`, `domain/`, `data/`
3. Use Riverpod providers for state management
4. Build screens with `ConsumerWidget`
5. Navigate using GoRouter named routes
6. Reuse widgets from `lib/src/core/widgets/`

### When Adding UI Components
1. Create in `lib/src/core/widgets/`
2. Prefer stateless components
3. Use `ConsumerWidget` only if directly consuming Riverpod state
4. Document with code comments

### When Modifying Database Access
1. Update `MutashabihatRepository` (read-only)
2. Defensive clamping for bounds checking
3. Add corresponding Riverpod provider
4. Test with injected test database

### Text & Localization
1. Use localized strings via `AppLocalizations.of(context)!.keyName`
2. Add Arabic text to `lib/l10n/app_ar.arb`
3. Run `flutter gen-l10n` after changes
4. Always wrap Arabic content with `Directionality(textDirection: TextDirection.rtl)`

## Experimental Code
`lib/revirpod_play_arround/` is a sandbox for experiments and is untracked by git.
