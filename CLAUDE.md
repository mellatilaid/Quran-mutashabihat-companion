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

**Database is read-only.** `app.db` ships as a pre-built asset built externally by `import_mutashabihat.py` (not in repo). It is copied to `getApplicationDocumentsDirectory()` on first launch and never mutated by the app. Any user-generated data (future: favorites, mnemonic tips) must go in a separate writable database.

**Defensive clamping in repository.** Some phrase occurrence records have `word_to` values beyond the actual ayah length (e.g., phrase 4970 / ayah 48:10). `MutashabihatRepository` clamps these to valid bounds before returning data — do not remove this logic without checking the data.

**AyahKey composite key.** `FutureProvider.family` requires a single hashable parameter. The custom `AyahKey(surahId, ayahNum)` class in `lib/src/core/providers.dart` provides this for the `ayahDetailProvider`.

**Typography.** All text styles globally use the Amiri font (Google Fonts) for Arabic. The theme is configured in `lib/src/main.dart` with Material 3, green primary color (`#1B5E20`), and `Directionality(textDirection: TextDirection.rtl)` wrapping Arabic content.

## State Management

Riverpod 3 with `ConsumerWidget` + `ref.watch()`. Providers are in `lib/src/core/providers.dart`:

- `mutashabihatRepositoryProvider` — shared `MutashabihatRepository` instance
- `surahsProvider` — all surahs for Screen 1
- `mutashabihatAyahsProvider(surahId)` — ayahs for Screen 2
- `ayahDetailProvider(AyahKey)` — word/highlight data for Screen 3
- `phraseProvider(phraseId)` — phrase metadata for Screen 4
- `phraseComparisonProvider(phraseId)` — all occurrences for Screen 4

## Routing with GoRouter

All screen navigation uses **GoRouter** (defined in `lib/src/core/router.dart`). Routes follow this pattern:

```dart
GoRoute(
  path: '/surah/:id',
  builder: (context, state) => MutashabihatAyahsScreen(
    surahId: int.parse(state.pathParameters['id']!),
  ),
)
```

Named routes for convenience:

- `'/'` — `SurahIndexScreen`
- `'/surah/:id'` — `MutashabihatAyahsScreen`
- `'/ayah/:surahId/:ayahNum'` — `AyahDetailScreen`
- `'/phrase/:phraseId'` — `PhraseComparisonScreen`

Access via `context.go('/surah/1')` or `context.goNamed('surahDetail', pathParameters: {'id': '1'})` in ConsumerWidget code.

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

Always use `ConsumerWidget` for screens and wrap `ref.watch()` calls at the top of the build method. Lift providers into widget parameters only when reusing the same component with different providers.

## Theme Management (Dark & Light)

Theme configuration in `lib/src/core/theme/app_theme.dart` exports two themes:

```dart
final lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  primaryColor: Color(0xFF1B5E20), // Dark green
  scaffoldBackgroundColor: Color(0xFFFAFAFA),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1B5E20),
    foregroundColor: Colors.white,
  ),
  textTheme: GoogleFonts.amiriTextTheme(
    ThemeData.light().textTheme,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  primaryColor: Color(0xFF66BB6A), // Light green
  scaffoldBackgroundColor: Color(0xFF121212),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF1B5E20),
    foregroundColor: Colors.white,
  ),
  textTheme: GoogleFonts.amiriTextTheme(
    ThemeData.dark().textTheme,
  ),
);
```

In `lib/src/main.dart`, apply via a Riverpod provider (`themeProvider`) to allow runtime theme switching:

```dart
final themeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ref.watch(themeProvider) ? ThemeMode.dark : ThemeMode.light,
)
```

Toggle theme with: `ref.read(themeProvider.notifier).state = !ref.read(themeProvider);`

## Localization (Arabic)

Localization setup uses **flutter_localizations** and **intl**. Messages are defined in `lib/l10n/app_ar.arb` (Arabic) and generated into Dart code.

### File Structure

- `lib/l10n/app_ar.arb` — all Arabic strings (key-value pairs)
- `lib/generated/l10n/app_localizations.dart` — auto-generated by `flutter gen-l10n`
- `lib/generated/l10n/app_localizations_ar.dart` — Arabic implementation

### pubspec.yaml Configuration

```yaml
flutter:
  generate: true

flutter_gen:
  outputs_dir: lib/generated
  line_length: 80
```

### Usage in Code

In `lib/src/main.dart`:

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('ar'),
  ],
  home: const MyApp(),
)
```

Access strings in widgets:

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(l10n.surahListTitle); // e.g., "قائمة السور"
  }
}
```

### Adding New Strings

1. Add to `lib/l10n/app_ar.arb`:

   ```json
   "newString": "النص العربي"
   ```

2. Run: `flutter gen-l10n`

3. Use: `AppLocalizations.of(context)!.newString`

For now, **only Arabic (`ar`) is supported**. To add more languages later, create `app_en.arb`, `app_fr.arb`, etc., and update `supportedLocales` in `lib/src/main.dart`.

## Untracked Experimental Code

`lib/revirpod_play_arround/` is a sandbox for Riverpod experiments and is not part of the main app. It is untracked by git.
