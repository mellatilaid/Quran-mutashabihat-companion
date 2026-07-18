# Mutashabihat Companion — Flutter data layer

This is the repository/provider layer that sits on top of `app.db`
(built by `import_mutashabihat.py`). It implements the four screens from
the SDD (§5) as straight SQL queries, plus a database bootstrap step.

## Files

```
lib/
  data/
    database_helper.dart        # copies app.db asset -> writable dir, opens it
  models/
    models.dart                 # Surah, AyahListItem, QuranWord, HighlightRange,
                                 # AyahDetail, Phrase, PhraseOccurrenceDetail
  repositories/
    mutashabihat_repository.dart  # one method per screen, raw SQL
  providers/
    mutashabihat_providers.dart   # Riverpod FutureProviders wrapping the repo
  screens/
    example_usage.dart          # minimal widgets showing each provider in use
```

## Setup

1. Add dependencies to `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter_riverpod: ^2.5.0
     sqflite: ^2.3.0
     path: ^1.9.0
     path_provider: ^2.1.0
   ```

2. Put the prebuilt database at `assets/db/app.db` and declare it:
   ```yaml
   flutter:
     assets:
       - assets/db/app.db
   ```

3. Wrap your app in a `ProviderScope` (standard Riverpod setup):
   ```dart
   void main() => runApp(const ProviderScope(child: MyApp()));
   ```

4. Use the screens/providers as shown in `example_usage.dart`.

## Design notes

- **`app.db` is opened read-only.** It's a static, prebuilt dataset —
  the app never writes to it. This also means shipping an updated
  `app.db` in a future release can safely overwrite the copied file
  without any migration logic.

- **Future content (SDD §7)** — `mnemonic_tips`, `favorites`,
  `revision_history`, etc. — should live in a **separate, writable**
  database (e.g. `user_data.db`), not inside `app.db`. Keeping
  user-generated data and the prebuilt dataset in different files means
  you can regenerate/re-ship `app.db` at any time without touching (or
  risking) anything the user has saved.

- **The one known data quirk** (phrase 4970, ayah 48:10, word range
  reaching past the ayah's actual word count — see the importer's
  cross-check output) is handled defensively in
  `MutashabihatRepository.getAyahDetail` / `getPhraseComparison` by
  clamping `word_to` to the ayah's real max word index, rather than
  special-casing that one row.

- **Screen 4 performance**: `getPhraseComparison` issues one `words`
  query per occurrence. Since a phrase typically has well under ~15
  occurrences (the SDD's own example tops out around 13), this is fine
  in practice. If a future phrase has dramatically more occurrences,
  this can be collapsed into a single query using `WHERE (surah, ayah)
  IN (...)` and grouping in Dart instead of SQL.
