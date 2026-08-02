# Phase 1 Data Model: Surah Search & Ayah Detail Enhancements

## Storage overview

Two SQLite databases remain separate, per the app's read-only/writable split (Principle I):

| Database | Role | Change in this feature |
|---|---|---|
| `app.db` (asset, read-only) | Quran text, surahs, phrases, phrase_occurrences | None — read-only, untouched. |
| `user_data.db` (writable, `UserDataDatabaseHelper`) | User-generated data | Version bumps 1 → 2: adds `ayah_notes` table. `favorites` table unchanged. |

## Entities

### Favorite (existing — `favorites` table, unchanged)

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | |
| `surah_id` | INTEGER NOT NULL | |
| `ayah_num` | INTEGER NOT NULL | |
| `note` | TEXT NULLABLE | Legacy column — left in place but **no longer written to** by this feature; personal notes now live exclusively in `ayah_notes` (see below). |
| `added_at` | TEXT NOT NULL | ISO-8601 |

Constraint: `UNIQUE(surah_id, ayah_num)`. Index: `idx_favorites_surah_id`.

Maps to Dart model `FavoriteAyah` (`lib/src/core/models/user_data_models.dart`) — unchanged.

Validation rules: none beyond uniqueness (favoriting is a boolean toggle keyed by surah+ayah — FR-006, FR-007).

State transitions: `unfavorited → favorited` (insert/replace), `favorited → unfavorited` (delete). No other states.

### Ayah Note (NEW — `ayah_notes` table)

| Column | Type | Notes |
|---|---|---|
| `id` | INTEGER PK AUTOINCREMENT | |
| `surah_id` | INTEGER NOT NULL | |
| `ayah_num` | INTEGER NOT NULL | |
| `note_text` | TEXT NOT NULL | 1–500 chars after trimming; empty/whitespace-only never persisted (FR-013). |
| `updated_at` | TEXT NOT NULL | ISO-8601, set on every insert/update. |

Constraint: `UNIQUE(surah_id, ayah_num)` — "at most one note exists per ayah at a time" (spec Key Entities). Index: `idx_ayah_notes_surah_id`.

New Dart model, added to `lib/src/core/models/user_data_models.dart`:

```dart
class AyahNote {
  final int id;
  final int surahId;
  final int ayahNum;
  final String noteText;
  final DateTime updatedAt;
  // fromMap / toMap / copyWith, same shape as FavoriteAyah
}
```

Validation rules (enforced in the UI layer before the repository call, per FR-013/FR-013a/FR-013b):
- Reject save if `noteText.trim().isEmpty`.
- Reject save if `noteText.trim().length > 500`.
- Input widget is a multi-line, expanding `TextField`/`TextFormField` (`maxLines: null`, `maxLength: 500`).

State transitions:
- *no note* → *note exists*: user enters text and confirms → `saveNote` (insert).
- *note exists* → *note exists (edited)*: user edits and confirms → `saveNote` (upsert via `ConflictAlgorithm.replace`).
- *note exists* → *no note*: user taps remove → `ConfirmDialog` shown → only on confirm → `deleteNote`. Declining leaves state unchanged (FR-012).

Relationship: keyed by the same `(surah_id, ayah_num)` composite identity as `Favorite`, but **no foreign-key dependency between the two tables** — a note can exist for an ayah that is not favorited, and vice versa (this is the reason a new table is introduced instead of reusing `favorites.note`; see [research.md](./research.md) §3).

### Surah (existing — `app.db`, no schema change)

Used for search filtering only. Existing fields `nameArabic`, `nameSimple` (already loaded by `surahsProvider`) are matched against the normalized query. No new attributes.

## Derived / in-memory concepts (no new storage)

- **Normalized search string**: `normalizeForSearch(String) -> String` — pure function, not persisted (see research.md §1).
- **Phrase marker color**: derived at render time as `palette[index % palette.length]` from `AyahDetail.phraseIds` (existing getter, unchanged) — not persisted, deterministic by construction (FR-015).
- **Phrase occurrence count** (for the redesigned list): already available per-phrase via the existing `phraseProvider(phraseId) -> Phrase.occurrenceCount` — no new query needed; the screen watches `phraseProvider` once per `phraseId` in `ayahDetail.phraseIds`.
- **Mnemonic-section-enabled flag**: `mnemonicSectionEnabledProvider` (`Provider<bool>`) wrapping the `kMnemonicSectionEnabled` constant — not persisted.

## Repository surface changes

See [contracts/user-data-repository.md](./contracts/user-data-repository.md) for the full method-level contract.
