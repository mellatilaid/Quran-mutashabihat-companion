# Quran Mutashabihat App — Full Design Implementation Plan

## Context

The app has a working data layer (SQLite, Riverpod, 4 proof-of-concept screens in `lib/files/`) but no real UI design applied. The `app_desing_specs/` folder contains a complete interactive prototype with 12 screens, a teal/gold/rose design system, and 3 new feature tabs. This plan builds the full designed app from the current skeleton.

---

## Phase 1 — Project Structure Migration

Move flat `lib/files/` code to the `lib/src/` feature-first architecture defined in CLAUDE.md.

### Tasks
- [ ] Add missing dependencies to `pubspec.yaml`: `go_router`, `flutter_localizations`, `intl`
- [ ] Create directory tree under `lib/src/`: `core/constants/`, `core/theme/`, `core/widgets/`, `core/services/`, `core/router.dart`, `core/providers.dart`, `features/surah_index/`, `features/mutashabihat_ayahs/`, `features/ayah_detail/`, `features/phrase_comparison/`, `features/favorites/`, `features/my_ayahs/`, `features/profile/`
- [ ] Move `lib/files/models.dart` → `lib/src/core/models.dart`
- [ ] Move `lib/files/database_helper.dart` → `lib/src/core/services/database_helper.dart`
- [ ] Move `lib/files/mutashabihat_repository.dart` → `lib/src/core/services/mutashabihat_repository.dart`
- [ ] Move `lib/files/mutashabihat_providers.dart` → `lib/src/core/providers.dart`
- [ ] Rewrite `lib/src/main.dart` to only contain `ProviderScope` + `runApp`
- [ ] Create `lib/src/app.dart` with `MaterialApp.router` shell
- [ ] Delete `lib/files/` after all references updated
- [ ] Run `flutter analyze` — zero errors

---

## Phase 2 — Design System

Translate `app_desing_specs/project/uploads/mutashabihat_design_tokens.json` into Flutter theme constants.

### Tasks
- [ ] Create `lib/src/core/constants/design_tokens.dart` with all color, spacing, and radius constants:
  - Light colors: teal `#0F6B62`, teal-soft `#E4F0EE`, gold `#B8862E`, gold-soft `#F6E9CE`, rose `#9C4E68`, rose-soft `#F3E2E8`, paper `#FBF7EF`, card `#FFFFFF`, ink `#20302C`, ink-soft `#5C6B67`, border `#E2DAC7`, danger `#A34632`, danger-soft `#FBEAE5`
  - Dark color mirrors (teal `#4FBFAE`, gold `#E3B45C`, paper `#121917`, card `#1B2422`, ink `#EDEDE4`, etc.)
  - Spacing scale: xs=4, sm=8, md=12, lg=16, xl=20, xxl=24
  - Radius scale: sm=6, md=8, lg=12, xl=16, xxl=24, full=999
- [ ] Create `lib/src/core/theme/app_theme.dart` with `lightTheme` and `darkTheme` (`ThemeData`):
  - Typography: `displayLarge`/`headlineMedium` → Newsreader 600, `bodyLarge`/`bodyMedium` → Amiri 400, `labelSmall`/`labelMedium` → Inter 600
  - Light: teal primary, paper scaffold background, white card color
  - Dark: dark-teal primary, dark-paper background, dark-card color
- [ ] Add `themeProvider` (`StateProvider<ThemeMode>`) to `lib/src/core/providers.dart`
- [ ] Add `arabicFontSizeProvider` (`StateProvider<double>`) with values 17.0 / 20.0 / 22.0
- [ ] Wire themes in `lib/src/app.dart`: `theme: lightTheme, darkTheme: darkTheme, themeMode: ref.watch(themeProvider)`
- [ ] Run `flutter analyze` — zero errors

---

## Phase 3 — Core Widget Library

Build all shared UI components in `lib/src/core/widgets/`.

### Tasks
- [ ] `top_bar.dart` — `AppTopBar`: 56px height, Newsreader 600 18px title, optional back chevron (left) and action widget (right)
- [ ] `bottom_nav_bar.dart` — `AppBottomNavBar`: 4 tabs (Index, Favorites, My Ayahs, Profile), teal active color, Inter 11px labels, 64px height
- [ ] `pill_badge.dart` — `PillBadge`: 3 tone variants (teal/gold/rose), Inter 11px 600 weight, full border-radius
- [ ] `ayah_marker.dart` — `AyahMarker`: gold 10-point star polygon (SVG via `CustomPaint`), Arabic-Indic numeral centered (Amiri 700), default 26px
- [ ] `arabic_line.dart` — `ArabicLine`: RTL `Wrap` of word spans, accepts `List<HighlightRange>` (background tint + bold) and optional `diffAt` index (3px danger underline), `activePhraseId` filter support, configurable font size via `arabicFontSizeProvider`
- [ ] `audio_play_button.dart` — `AudioPlayButton`: play/pause icon + 40px progress bar, auto-increments every 100ms when playing, loops at 100% — UI-only, no audio source
- [ ] `share_note_button.dart` — `ShareNoteButton`: copies text to clipboard, shows "Copied" checkmark for 1.5s, greyed out if text empty
- [ ] `toast.dart` — `AppToast`: fixed-position bottom (76px), dark background, message + optional Undo button, auto-dismisses after 4s
- [ ] `confirm_dialog.dart` — `ConfirmDialog`: bottom-sheet, rounded-top 48px, AlertTriangle + title (Newsreader 16px) + message (Inter 13.5px muted), Cancel outline + Confirm danger buttons

---

## Phase 4 — Navigation (GoRouter)

**File:** `lib/src/core/router.dart`

### Tasks
- [ ] Create `GoRouter` with `StatefulShellRoute.indexedStack` wrapping all 4 tabs (preserves tab state across switches)
- [ ] Define persistent `Scaffold` shell with `AppBottomNavBar`, `currentIndex` derived from `GoRouterState`
- [ ] Define routes:
  - `/` → `SurahIndexScreen`
  - `/surah/:id` → `MutashabihatAyahsScreen`
  - `/ayah/:surahId/:ayahNum` → `AyahDetailScreen`
  - `/phrase/:phraseId` → `PhraseComparisonScreen`
  - `/favorites` → `FavoritesScreen`
  - `/favorites/test` → `FavoritesTestScreen`
  - `/my-ayahs` → `MyAyahsScreen`
  - `/my-ayahs/add` → `MyAyahsAddScreen`
  - `/my-ayahs/:surahId/:ayahNum` → `MyAyahsDetailScreen`
  - `/my-ayahs/test` → `MyAyahsTestScreen`
  - `/profile` → `ProfileScreen`
- [ ] Replace all `Navigator.push()` calls in existing screens with `context.go()`
- [ ] Run `flutter run` — app launches with 4-tab bottom nav

---

## Phase 5 — Index Tab (4 Screens)

### Tasks

#### Screen 1: `SurahIndexScreen`
**File:** `lib/src/features/surah_index/presentation/surah_index_screen.dart`
- [ ] `AppTopBar`: "Mutashabihat Companion", no back
- [ ] Segmented toggle: "Surahs" | "Most Confusable" (local `StateProvider`)
- [ ] Surahs mode: search input (filters by Arabic/English name) + `ListView` of `SurahListTile` items (teal circle badge + Amiri Arabic 18px + Inter English 12.5px + gold `PillBadge` "N ayahs")
- [ ] Most Confusable mode: `ListView` sorted by `occurrence_count` desc — flame icon + phrase sample (Amiri 16px) + gold `PillBadge` count — tap → `/phrase/:id`
- [ ] Add `mostConfusableProvider` (FutureProvider) and `searchPhraseSample` repository query

#### Screen 2: `MutashabihatAyahsScreen`
**File:** `lib/src/features/mutashabihat_ayahs/presentation/mutashabihat_ayahs_screen.dart`
- [ ] `AppTopBar`: Arabic + English surah name, back button
- [ ] `ListView` of ayah items: `AyahMarker` (gold rosette + number) + `ArabicLine` 19px (no highlights) — tap → `/ayah/:surahId/:ayahNum`

#### Screen 3: `AyahDetailScreen` (Mutashabihat View)
**File:** `lib/src/features/ayah_detail/presentation/ayah_detail_screen.dart`
- [ ] `AppTopBar`: "Surah N — Ayah N" + back + heart toggle (calls `toggleFavorite`)
- [ ] Ayah card: white, rounded-lg, bordered — `ArabicLine` with all phrase highlights + `AyahMarker`
- [ ] "Similar Phrases Found Here (N)" section with phrase selector buttons (colored dot + label)
- [ ] Tapping a colored dot sets `activePhraseId` local state → updates `ArabicLine` to show only that phrase; tap again to clear
- [ ] Helper text if 2+ phrases: "Tap a colored dot to isolate that phrase in the ayah above."
- [ ] Mnemonic section: gold-tinted card with system tip text (from `app.db`)
- [ ] My Note section: `ShareNoteButton` in header; empty → dashed "Add your own mnemonic" button → expands textarea; persists to `notes` table

#### Screen 4: `PhraseComparisonScreen`
**File:** `lib/src/features/phrase_comparison/presentation/phrase_comparison_screen.dart`
- [ ] `AppTopBar`: "Phrase #ID — Comparison" + back
- [ ] Gold-tinted explanation box
- [ ] `ListView` of occurrence cards: `PillBadge`("surah:ayah") + `AudioPlayButton` + `ArabicLine` with goldSoft phrase highlight + `diffAt` danger underline

---

## Phase 6 — Favorites Tab

### Tasks

#### Data layer
- [ ] Create `lib/src/core/services/user_database_helper.dart` — writable SQLite at `user_data.db` (separate from read-only `app.db`)
- [ ] Create `favorites` table: `(surah, ayah, created_at, PRIMARY KEY (surah, ayah))`
- [ ] Create `test_attempts` table: `(id, surah, ayah, source, correct, attempted_at)`
- [ ] Add `favoritesRepository` and providers: `favoritesProvider`, `favoriteStatusProvider(AyahKey)`, `addFavorite()`, `removeFavorite()`

#### Screen 5: `FavoritesScreen`
**File:** `lib/src/features/favorites/presentation/favorites_screen.dart`
- [ ] `AppTopBar`: "Favorites"
- [ ] Empty state message when no favorites
- [ ] `ListView`: filled heart icon + "surah:ayah" label + pills ("Due" if `daysSinceAttempt >= 5`, "N missed" if misses > 0) + chevron
- [ ] Swipe/tap → immediate remove + `AppToast` with Undo (4s restore)
- [ ] "Start Test Mode" gold button (visible when list non-empty)

#### Screen 6: `FavoritesTestScreen` (MCQ)
**File:** `lib/src/features/favorites/presentation/favorites_test_screen.dart`
- [ ] `AppTopBar`: "Question N of TOTAL" + exit button → `ConfirmDialog` if mid-session
- [ ] Progress bar (teal fill, thin)
- [ ] Question card: surah:ayah ref + partial ayah with blank (`ArabicLine`)
- [ ] "WHICH ENDING BELONGS HERE?" label
- [ ] 4 choice buttons — tap reveals correct (teal border + checkmark) or wrong (danger border + X), all disabled after selection
- [ ] "Next / Finish" button appears post-selection
- [ ] Completion screen: large score circle, contextual message, Done button

---

## Phase 7 — My Ayahs Tab

### Tasks

#### Data layer
- [ ] Create `my_ayahs` table: `(surah, ayah, note, created_at, PRIMARY KEY (surah, ayah))`
- [ ] Create `notes` table: `(surah, ayah, phrase_id NULLABLE, body, updated_at)`
- [ ] Add `myAyahsRepository` and providers: `myAyahsProvider`, `addMyAyah()`, `removeMyAyah()`, `updateNote()`
- [ ] Add `searchAyahs(query)` method to `MutashabihatRepository` (queries `app.db`)

#### Screen 7: `MyAyahsScreen`
**File:** `lib/src/features/my_ayahs/presentation/my_ayahs_screen.dart`
- [ ] `AppTopBar`: "My Ayahs" + Plus icon → `/my-ayahs/add`
- [ ] Empty state with description
- [ ] `ListView`: bold "surah:ayah" + user note (muted) + trash icon (remove + Undo toast) + chevron

#### Screen 8: `MyAyahsAddScreen`
**File:** `lib/src/features/my_ayahs/presentation/my_ayahs_add_screen.dart`
- [ ] `AppTopBar`: "Add a difficult ayah" + back
- [ ] Search input (queries `app.db`) — results appear after 2+ chars
- [ ] Results: "surah:ayah" muted + Amiri 17px ayah text + Plus icon → adds entry, returns to list

#### Screen 9: `MyAyahsDetailScreen` (Plain — no Mutashabihat)
**File:** `lib/src/features/my_ayahs/presentation/my_ayahs_detail_screen.dart`
- [ ] `AppTopBar`: "Surah N — Ayah N" + back + trash icon
- [ ] Ayah card: `ArabicLine` (no highlights)
- [ ] My Note section: always-visible textarea ("Why is this one hard to recall?"), `ShareNoteButton`
- [ ] Trash → remove + Undo toast

#### Screen 10: `MyAyahsTestScreen` (Flashcard)
**File:** `lib/src/features/my_ayahs/presentation/my_ayahs_test_screen.dart`
- [ ] Same shell as MCQ (TopBar + progress bar + exit confirm)
- [ ] Hint state: "RECALL THE REST" label + first 3 words + "· · ·" + "Reveal full ayah" button
- [ ] Full state: complete ayah + "Missed it" (red, X icon) | "Got it" (teal, checkmark icon) buttons
- [ ] Completion screen identical to Favorites test

---

## Phase 8 — Profile Tab

### Tasks

#### Screen 11: `ProfileScreen`
**File:** `lib/src/features/profile/presentation/profile_screen.dart`
- [ ] `AppTopBar`: "Profile"
- [ ] Stats card: teal-soft circular avatar (favorites count) + "N ayahs saved" label
- [ ] "APPEARANCE" section:
  - Dark mode toggle row (Moon/Sun icon + toggle pill) — updates `themeProvider`
  - Arabic text size row (Type icon + 3 A-buttons) — updates `arabicFontSizeProvider`
- [ ] "CONFIDENCE BY SURAH" section: progress bars per surah derived from `test_attempts` grouped by surah (correct / total)
- [ ] "PROGRESS" section: "Reset test history" row (clears `test_attempts` table), "About this app" row

---

## Phase 9 — Localization

### Tasks
- [ ] Create `lib/l10n/app_ar.arb` with Arabic keys for all UI strings (screen titles, section headers, buttons, empty states, error messages)
- [ ] Add `flutter: generate: true` in `pubspec.yaml` and configure `l10n.yaml`
- [ ] Run `flutter gen-l10n` to generate `lib/generated/l10n/`
- [ ] Replace all hardcoded Arabic/English strings in widgets with `AppLocalizations.of(context)!.*`
- [ ] Verify RTL layout correct across all screens

---

## Critical Files Reference

| File | Action | Phase |
|------|--------|-------|
| `pubspec.yaml` | Add go_router, flutter_localizations, intl | 1 |
| `lib/src/main.dart` | ProviderScope + runApp only | 1 |
| `lib/src/app.dart` | MaterialApp.router + theme wiring | 1 |
| `lib/src/core/constants/design_tokens.dart` | CREATE | 2 |
| `lib/src/core/theme/app_theme.dart` | CREATE | 2 |
| `lib/src/core/providers.dart` | MOVE + expand | 1–2 |
| `lib/src/core/router.dart` | CREATE | 4 |
| `lib/src/core/widgets/*.dart` | CREATE (9 widgets) | 3 |
| `lib/src/core/services/user_database_helper.dart` | CREATE | 6 |
| `lib/src/features/*/` | CREATE (12 screens) | 5–8 |
| `lib/l10n/app_ar.arb` | CREATE | 9 |
| `lib/files/` | DELETE after migration | 1 |

## Reuse (Do Not Rewrite)
- `MutashabihatRepository` defensive clamping (lines 93–99) — **keep as-is**
- `AyahKey` composite key class
- All 6 existing Riverpod providers
- `DatabaseHelper` singleton

---

## Verification Checklist

- [ ] `flutter pub get` — no errors
- [ ] `flutter analyze` — zero warnings
- [ ] App launches with 4-tab bottom nav
- [ ] Index tab: surah list, toggle, search, navigation chain works
- [ ] Phrase highlights correct teal/gold/rose per design tokens
- [ ] Phrase dot isolation (tap to filter) works in Ayah Detail
- [ ] Phrase Comparison shows diff underline (danger color)
- [ ] Favorites: add/remove with Undo toast, Due badge logic
- [ ] MCQ test: questions, correct/wrong feedback, score screen
- [ ] My Ayahs: add search, note edit, delete with Undo
- [ ] Flashcard test: hint → reveal → self-grade → score
- [ ] Profile: dark mode toggle switches theme app-wide
- [ ] Profile: font size selector updates Arabic text size app-wide
- [ ] `flutter test` — all tests pass
