# Mutashabihat Companion — Design Brief

Context for whoever picks this up next (including Claude Design). Pairs with
`mutashabihat_mockup.jsx` (interactive prototype) and
`mutashabihat_design_tokens.json` (Tokens Studio-format design system).

## What this app is

A companion tool for Huffaz to resolve confusion between Mutashabihat —
similar/repeated verses across the Quran. It is explicitly **not** a general
Quran reader: every screen exists to answer one question — *"I'm confused
about this ayah, show me the similar verses and explain the difference."*

## Information architecture

Four bottom tabs, each with its own navigation stack:

```
Index                Favorites            My Ayahs             Profile
 └ Surahs / Most       └ Favorited ayahs    └ Difficult ayahs     └ Theme
   Confusable toggle     → Ayah Detail        (search & add)      → Font size
 └ Ayah list           → Test Mode          → Ayah Detail         → Confidence
 └ Ayah Detail                                (plain, no quiz)      by surah
 └ Phrase Comparison                        → Test Mode
```

**Ayah Detail is one shared screen**, reached from both Index and Favorites —
not duplicated per flow. Whether the user arrives by browsing a surah or by
tapping a favorite, they land in the same place, with the same ♥ toggle,
phrase list, mnemonic, and notes section. This was a deliberate consistency
decision, not an accident of reuse.

## Design system summary

- **Color**: teal (primary/nav) + gold (highlight/accent) are load-bearing —
  pulled directly from what was already committed in the Flutter code (teal
  seed color in `main.dart`, gold/amber highlight in the repository layer).
  A third hue, **rose**, exists only to distinguish a second phrase inside
  one ayah — never used for nav, buttons, or anything primary.
- **Typography**: Amiri (Arabic ayah text — a real Quran-suitable typeface,
  not a generic Arabic font), Newsreader (headings), Inter (UI body/labels).
- **Spacing/radius**: standard 4/8/12/16/20/24px spacing scale,
  6/8/12/16/24px radius scale, full pill/circle at 999px.
- Full values live in `mutashabihat_design_tokens.json`, split into
  `global` (type/spacing/radius) + `light`/`dark` (color), with a `$themes`
  block so Light/Dark import as an actual working theme switch.

## Component inventory

| Component | Purpose |
|---|---|
| `TopBar` | Screen header, optional back button, optional right-side action |
| `TabBar` | 4-tab bottom nav |
| `Pill` | Small status/count badge (teal/gold/rose tones) |
| `AyahMarker` | Ornate ayah-end rosette + Arabic-Indic digit, replacing a plain numbered circle |
| `ArabicLine` | Renders a word array with optional multi-region highlights + one "diff" underline + trailing end-marker |
| `AudioPlayButton` | Play/pause + progress, **UI-only placeholder**, no audio wired |
| `ShareNoteButton` | Copies note text to clipboard |
| `Toast` | Bottom-pinned undo notification, 4s auto-dismiss |
| `ConfirmDialog` | Bottom-sheet confirmation, used for "leave test in progress" |

## Key interaction decisions (with rationale)

- **Shared-phrase highlight vs. diff-word underline are visually distinct
  layers** (Screen 4). The background tint shows *what's common* across
  occurrences; the underline marks *the one word that's actually different*
  — the real cognitive task the app exists to support.
- **Tap a phrase's colored dot to isolate it** in the ayah card (Screen 3),
  for ayahs containing more than one confusable phrase.
- **Test Mode splits by tab, not by a single shared quiz type**:
  - Favorites → multiple choice, distractors built from real phrase variants
  - My Ayahs → self-graded flashcard, since these aren't phrase-pairs with a
    natural "wrong answer" — just hard-to-recall ayahs
  - My Ayahs flashcards show a **hint** (first 3 words) before reveal, never
    the full ayah up front — otherwise it isn't testing recall at all.
- **Undo, not confirm, on quick deletes.** Removing a favorite or a My Ayahs
  entry happens immediately with a 4s undo toast, rather than an "are you
  sure?" dialog — reserving the heavier confirm-dialog treatment for the one
  place data loss is expensive: mid-test-session exit.

## Data model implications

Two more writable tables beyond what's in the read-only `app.db`:

| Table | Notes |
|---|---|
| `favorites (surah, ayah, created_at)` | |
| `my_ayahs (surah, ayah, note, created_at)` | |
| `notes (surah, ayah, phrase_id NULL, body, updated_at)` | nullable `phrase_id` — a note can be about the whole ayah or one specific phrase |
| `mnemonic_tips (phrase_id, body)` | pre-authored, ships **inside** `app.db`, read-only |
| `test_attempts (surah, ayah, source, correct, attempted_at)` | powers "due for review" and the confidence-by-surah stat |

Keeping user data in a separate writable database (not inside `app.db`) means
shipping an updated `app.db` later never risks wiping anything the user saved
— this was already a constraint from the Flutter repository layer, carried
forward here.

## Open questions / things that are placeholders, not decisions

Flagging these explicitly so they don't get mistaken for settled choices:

1. **The MCQ / flashcard split for Test Mode is my recommendation, not
   something you specified.** Worth confirming it's actually the right
   mental model before building it for real.
2. **Phrase #512 (the rose-colored second phrase in 2:112) is fabricated**,
   purely to demonstrate multi-phrase color differentiation. It is not real
   Mutashabihat data — don't ship it as-is.
3. **Diff-word detection is hardcoded per mock item** (`diffAt`). The real
   app needs actual logic to compute which word differs between occurrences
   of the same phrase — a small algorithm to add to the importer or
   repository layer, not something `phrases.json` provides directly.
4. **Audio playback is UI-only.** No reciter audio source is wired up; the
   play button demonstrates the interaction, not a working feature.
5. **"Due for review" threshold (5 days) is arbitrary**, a placeholder for a
   real spaced-repetition policy later.
6. **The ayah-end rosette is an approximation**, not a faithful reproduction
   of any specific mushaf's stop-marker glyph — worth a design pass if
   visual authenticity matters to you.
7. **"Most Confusable" currently ranks by `occurrence_count` alone** — worth
   deciding if `surah_count` (spread across the Quran) should factor in too,
   since a phrase appearing 6 times in one surah is a different kind of
   "confusable" than one appearing once each in 6 surahs.
