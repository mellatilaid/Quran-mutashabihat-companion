<!--
Sync Impact Report
- Version change: 1.0.0 → 1.1.0
- Modified principles: II. Testing Standards (NON-NEGOTIABLE) — expanded to
  explicitly require, for every new feature (not only repository/provider
  changes), unit tests for non-UI logic and widget tests for each new/changed
  interactive UI element and its key states, beyond the prior coarse
  per-screen loading/error/data check. Clarified that a spec stating explicit
  test scope (e.g., a Success Criterion) does not waive this default.
- Added sections: none
- Removed sections: none
- Templates requiring follow-up: none — plan/spec/tasks templates in
  .specify/templates/ read this file at runtime and contain no hardcoded
  references to specific principle names
- Deferred TODOs: none
-->

# Quran Mutashabihat App Constitution

## Core Principles

### I. Code Quality & Architecture Discipline
All code MUST follow the established feature-first architecture
(`lib/src/features/<feature>/{presentation,domain,data}`) and the layered data
flow: SQLite → `DatabaseHelper` → `MutashabihatRepository` → Riverpod
providers → `ConsumerWidget` screens → GoRouter. Screens MUST be
`ConsumerWidget`s that call `ref.watch()` at the top of `build()` and handle
`AsyncValue` states via `.when()` for loading/error/data — no ad-hoc state
management or bypassing providers to query the repository directly from a
widget. `flutter analyze` MUST pass with zero issues before any change is
considered complete. Reusable UI MUST live in `lib/src/core/widgets/` and
follow the existing stateless-vs-consumer split; providers are lifted into
widget parameters only when the same component is reused against a different
provider. The database is read-only: `app.db` MUST NOT be mutated by the app,
and any user-generated data requires a separate writable store. Defensive
data-correction logic (e.g., clamping out-of-range `word_to` values in
`MutashabihatRepository`) MUST NOT be removed without first verifying the
underlying data no longer requires it. Code MUST NOT introduce speculative
abstractions, unused parameters, or dead code paths.

Rationale: The app's maintainability depends on every feature following the
same predictable pipeline. Deviating from it (e.g., a screen querying SQLite
directly, or silent removal of clamping logic) has previously caused subtle,
hard-to-trace bugs tied to malformed source data.

### II. Testing Standards (NON-NEGOTIABLE)
Every change to repository or provider logic MUST be covered by a test before
being considered done. `MutashabihatRepository` MUST remain constructible
with an injectable database instance specifically so it can be tested against
an in-memory or fixture SQLite database — production code MUST NOT hardcode
the singleton `DatabaseHelper` in a way that prevents test injection. Tests
MUST cover: (a) defensive clamping and other edge-case data handling, (b)
provider family key equality (e.g., `AyahKey`), and (c) at least one widget
test per screen verifying the loading/error/data branches render correctly.
`flutter test` MUST pass before a change is merged. Bug fixes MUST include a
regression test that fails without the fix and passes with it.

Every new feature (not just repository/provider changes) MUST ship with unit
tests covering its non-UI logic (data-layer/persistence code, matching or
validation functions, derived-state computations, etc.) and widget tests
covering its new or materially changed interactive UI (new controls, dialogs,
input fields, list items) — not only the coarse per-screen loading/error/data
check in (c) above, but each newly introduced interactive element and its
key states (e.g., empty/filled, error, confirm/cancel). A feature's spec
SHOULD state its required unit/widget test scope explicitly (as a Success
Criterion or Clarification) so it carries through planning and task
breakdown; absence of that statement does NOT waive this principle — the
default coverage bar defined here still applies.

Rationale: The database is externally generated and read-only, so the app's
correctness hinges entirely on the repository and provider layer handling
real-world data irregularities correctly; untested changes to this layer are
the highest-risk source of user-facing breakage.

### III. User Experience Consistency
All Arabic textual content MUST render with the Amiri font via
`GoogleFonts.amiriTextTheme` and MUST be wrapped in RTL
(`Directionality(textDirection: TextDirection.rtl)`) where Arabic content is
displayed. All screens MUST support both `lightTheme` and `darkTheme` as
defined in `lib/src/core/theme/app_theme.dart` — no screen-local hardcoded
colors that break dark mode. All user-facing strings MUST be added to
`lib/l10n/app_ar.arb` and accessed through `AppLocalizations.of(context)!`;
literal Arabic strings MUST NOT be hardcoded inline in widgets. Navigation
MUST go through GoRouter using the routes defined in
`lib/src/core/router.dart` (`context.go` / `context.goNamed`) — no
`Navigator.push` bypassing the router. Shared visual patterns (phrase
highlighting via `PhraseHighlight`, ayah rendering via `AyahCard`/`WordList`,
list tiles via `SurahListTile`) MUST be reused rather than reimplemented per
screen, so highlighting, spacing, and typography stay identical across the
Surah Index, Mutashabihat Ayahs, Ayah Detail, and Phrase Comparison screens.

Rationale: The app's core value is letting users visually compare phrases
across ayahs; inconsistent highlighting, font, or theme handling between
screens directly undermines that comparison experience.

### IV. Performance Requirements
Long or scrollable lists (surah index, ayah lists, phrase occurrence lists)
MUST use lazy-building widgets (e.g., `ListView.builder`) rather than eagerly
building all children. Riverpod `FutureProvider` / `FutureProvider.family`
MUST be relied upon for caching repository results — screens MUST NOT
re-fetch the same data via redundant one-off queries when a provider already
holds it. The one-time asset-database copy in `DatabaseHelper` MUST remain
guarded so it only runs on first launch, never on every app start. All SQL
queries added to `MutashabihatRepository` MUST be scoped with appropriate
`WHERE`/indexed lookups rather than loading whole tables into memory and
filtering in Dart. Widget rebuilds MUST be scoped narrowly (e.g., watching
only the specific provider a widget needs) to avoid unnecessary full-screen
rebuilds on unrelated state changes.

Rationale: The app runs entirely against a local SQLite asset on mobile
hardware; unnecessary full-table scans, redundant fetches, or unbounded list
builds are the most likely sources of visible jank on lower-end devices.

## Quality Gates

Before a change is considered complete, all of the following MUST hold:
`flutter analyze` reports zero issues; `flutter test` passes in full; any new
or changed repository/provider logic has corresponding tests (Principle II);
any new user-facing string exists in `app_ar.arb` and is accessed via
`AppLocalizations` (Principle III); and any new list or data-fetch path
follows the lazy-loading and caching rules in Principle IV.

## Development Workflow

Changes are organized feature-first, mirroring `lib/src/features/`. New
screens or widgets follow the existing `ConsumerWidget` + provider pattern
before introducing any new state-management approach. Code review (self- or
peer-) MUST check the Quality Gates above prior to merge. The experimental
sandbox at `lib/revirpod_play_arround/` is explicitly out of scope for these
principles since it is untracked and not part of the shipped app.

## Governance

This constitution supersedes ad-hoc conventions for any conflict between
them. Amendments are made by editing this file, incrementing
`CONSTITUTION_VERSION` per semantic versioning (MAJOR for backward-
incompatible principle removal/redefinition, MINOR for a new principle or
materially expanded guidance, PATCH for clarifications/wording), and updating
`LAST_AMENDED_DATE`. All pull requests and reviews MUST verify compliance
with the Core Principles and Quality Gates above; any deviation MUST be
called out explicitly and justified in the PR description rather than left
implicit. Use `CLAUDE.md` at the repository root for day-to-day runtime
development guidance (commands, file layout, provider names); this
constitution governs the non-negotiable principles that guidance must not
contradict.

**Version**: 1.1.0 | **Ratified**: 2026-08-02 | **Last Amended**: 2026-08-02
