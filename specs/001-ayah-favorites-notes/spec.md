# Feature Specification: Surah Search & Ayah Detail Enhancements

**Feature Branch**: `001-ayah-favorites-notes`

**Created**: 2026-08-02

**Status**: Draft

**Input**: User description: "i wanna add some new options and some refoctors to this feature lib/src/features/index_tab/ so the first one is adding search field by surah in the first screen lib/src/features/index_tab/presentation/views/index_view.dart the second thing is refacot screen 3 lib/src/features/index_tab/presentation/views/ayah_detail_screen.dart ui to look like this desing [reference image] and addd the missing features like addd to favorites button and mnimonic and custom note optionn as well where when the user click on favorites the ayah will appear in favorites screen later , and for custom note it cached locally so when he enters this ayah later the note displayed to him also add remove note and update option as well, and for the mnimonic section it can be display or not but for now it will be not displayed"

## Clarifications

### Session 2026-08-02

- Q: Should the surah search match names even when the query ignores Arabic diacritics (tashkeel)? → A: Ignore diacritics — normalize both query and surah names by stripping Arabic diacritics/tashkeel before matching.
- Q: When a user chooses to remove a saved note on an ayah, should the app ask for confirmation before deleting it? → A: Confirm first — show a confirmation prompt before deleting the note.
- Q: Should there be a maximum character length for a personal ayah note, and if so what limit? → A: 500 characters — the input enforces this cap, with a counter as the limit approaches.
- Q: How should the distinguishing color marker for each phrase in the similar-phrases list be assigned? → A: Fixed palette cycling by position — colors assigned in list order from a small fixed palette, wrapping if there are more phrases than colors.
- Q: Should the personal note input support multiple lines of text, or is it a single-line field? → A: Multi-line — an expanding multi-line text area up to the 500-character limit.
- Q: What level of automated test coverage should this feature require before it's considered done — unit tests, widget tests, or both? → A: Unit + widget tests — unit tests for the favorites/notes data layer and diacritic-insensitive search matching, plus widget tests for the new/changed UI (search field, favorite toggle, note editor with confirm-delete, redesigned ayah detail layout).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Find a Surah quickly by searching (Priority: P1)

A user browsing the Surah Index screen wants to jump straight to a specific surah instead of scrolling through all 114 entries. They type part of the surah's name into a search field at the top of the list and the list narrows to matching surahs as they type.

**Why this priority**: This is the most requested navigational improvement and the simplest to deliver independently; it immediately reduces friction for the app's primary entry point (the surah list) and doesn't depend on any other change in this spec.

**Independent Test**: Can be fully tested by opening the Surah Index screen, typing a partial surah name (Arabic or transliterated) into the search field, and confirming the list shows only matching surahs, with the full list restored when the field is cleared.

**Acceptance Scenarios**:

1. **Given** the Surah Index screen is showing all 114 surahs, **When** the user types a partial surah name into the search field, **Then** the list updates to show only surahs whose name contains the typed text.
2. **Given** the user has typed a search query with no matching surah, **When** the query does not match any surah name, **Then** the screen shows a clear "no results" message instead of an empty list.
3. **Given** the user has an active search query, **When** the user clears the search field, **Then** the full list of 114 surahs is shown again.

---

### User Story 2 - Mark an ayah as favorite (Priority: P2)

While viewing an ayah's detail, a user wants to bookmark it so they can find it again later without renavigating through the surah and ayah list.

**Why this priority**: Favoriting is the simplest of the three new ayah-detail actions (no text input, no persistence of arbitrary content) and delivers standalone value — a user can mark ayahs of interest even before a dedicated favorites screen exists to list them.

**Independent Test**: Can be fully tested by opening an ayah's detail screen, tapping the favorite control, confirming its visual state changes to "favorited" and persists across app restarts, then tapping again to unfavorite.

**Acceptance Scenarios**:

1. **Given** an ayah detail screen for an ayah that is not favorited, **When** the user taps the favorite control, **Then** the control updates to show the ayah is favorited and this status is saved locally.
2. **Given** an ayah detail screen for an ayah that is already favorited, **When** the user taps the favorite control, **Then** the ayah is unfavorited and the saved status is removed.
3. **Given** an ayah was favorited in a previous session, **When** the user reopens that ayah's detail screen, **Then** the favorite control shows it as favorited.

---

### User Story 3 - Add, edit, and remove a personal note on an ayah (Priority: P2)

While viewing an ayah's detail, a user wants to write a short personal note (e.g., a memory aid or observation) that is saved locally and shown to them every time they return to that specific ayah, with the ability to later update or delete it.

**Why this priority**: Notes are the most complex of the three new capabilities (free-text input, persistence, edit/delete) but are independently valuable and testable without favorites or the mnemonic section existing.

**Independent Test**: Can be fully tested by opening an ayah with no existing note, adding note text, leaving and reopening the same ayah to confirm the note persists and displays, editing the note, and deleting it to confirm it no longer appears.

**Acceptance Scenarios**:

1. **Given** an ayah detail screen with no saved note, **When** the user opens the note section and enters text, **Then** the note is saved locally and displayed under the ayah's note section.
2. **Given** an ayah with a previously saved note, **When** the user reopens that ayah's detail screen, **Then** the saved note text is displayed automatically.
3. **Given** an ayah with a previously saved note, **When** the user edits the note text and confirms, **Then** the updated text replaces the old note and persists on next visit.
4. **Given** an ayah with a previously saved note, **When** the user chooses to remove the note, **Then** the app shows a confirmation prompt, and only upon confirming is the note deleted and the note section returned to its empty/"add note" state; declining the prompt leaves the note unchanged.
5. **Given** the user is editing a note, **When** the user leaves without confirming, **Then** the previously saved note (or empty state) is left unchanged.

---

### User Story 4 - Redesigned ayah detail layout (Priority: P3)

A user viewing an ayah's detail sees a visually restructured screen: a header showing the surah and ayah reference with a favorite toggle, the ayah text card, a "similar phrases found here" list showing each shared phrase with its occurrence count and a distinguishing color marker that can be tapped to isolate that phrase's highlight in the ayah text, and (when enabled) a mnemonic section, followed by the personal note section.

**Why this priority**: This is primarily a visual/structural refactor of existing functionality (phrase highlighting, phrase list) plus placement of the new favorite/note/mnemonic elements. It depends on Stories 2 and 3 for the actions it hosts, so it is sequenced after them, but the underlying phrase-comparison behavior already exists and is lower-risk to restructure last.

**Independent Test**: Can be fully tested by opening any ayah with multiple shared phrases and confirming the layout order (header, ayah card, similar-phrases list with counts and color markers, note section), and that tapping a phrase entry isolates its highlight in the ayah text as the current behavior already does.

**Acceptance Scenarios**:

1. **Given** an ayah with two or more shared phrases, **When** the ayah detail screen loads, **Then** each phrase is listed with a distinguishing color marker and its total occurrence count elsewhere in the Quran.
2. **Given** the similar-phrases list is showing, **When** the user taps one phrase entry, **Then** only that phrase's words are highlighted in the ayah text above, matching current tap-to-isolate behavior.
3. **Given** the mnemonic section is disabled by configuration, **When** the ayah detail screen loads, **Then** no mnemonic section is shown to the user.
4. **Given** an ayah with zero shared phrases, **When** the ayah detail screen loads, **Then** the similar-phrases section is omitted or shows an appropriate empty state rather than an empty list.

---

### Edge Cases

- What happens when the user searches for a surah using digits (surah number) instead of a name? [Reasonable default: search matches surah name only in this iteration; numeric surah lookup is out of scope — see Assumptions.]
- What happens when the user tries to save an empty note? [Empty/whitespace-only note should not be saved; the note section should stay in its empty "add note" state.]
- What happens when the device runs out of local storage while saving a favorite or note? [The action should fail gracefully with a visible error message and no partial/corrupted state.]
- What happens when the same ayah is opened from two different navigation paths (e.g., via surah browse vs. a future favorites list)? [Favorite/note state must be identical regardless of navigation path, since it is keyed by surah+ayah, not by navigation origin.]
- How does the app behave if a user un-favorites an ayah while a favorites list screen (future feature) is open showing it? [Out of scope for this spec; noted for the future favorites-screen feature.]

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Surah Index screen MUST provide a search field that filters the visible surah list by name as the user types.
- **FR-002**: The search MUST match against both the Arabic surah name and the transliterated/simple surah name.
- **FR-003**: The search MUST be case-insensitive, diacritic-insensitive (ignoring Arabic tashkeel marks on both the query and surah names), and MUST match partial, substring occurrences (not only prefixes).
- **FR-004**: When no surah matches the current search text, the screen MUST show a clear empty-state message instead of an empty list.
- **FR-005**: Clearing the search field MUST restore the full, unfiltered surah list.
- **FR-006**: The Ayah Detail screen MUST display a favorite toggle control associated with the currently viewed ayah.
- **FR-007**: Tapping the favorite control MUST persist the ayah's favorited/unfavorited status locally, independent of the read-only Quran database, and the status MUST survive app restarts.
- **FR-008**: The favorite status show on the Ayah Detail screen MUST reflect the persisted status for that specific surah + ayah combination every time it is opened.
- **FR-009**: The Ayah Detail screen MUST provide a personal note section allowing the user to add free-text notes for the currently viewed ayah.
- **FR-010**: A saved note MUST be persisted locally, keyed to the specific surah + ayah combination, and MUST be displayed automatically whenever that ayah's detail screen is reopened.
- **FR-011**: The user MUST be able to update the text of an existing note for an ayah, replacing the previously saved text.
- **FR-012**: The user MUST be able to remove an existing note for an ayah; the app MUST prompt for confirmation before deleting, and only after the user confirms does the note section return to its empty state.
- **FR-013**: The system MUST NOT save empty or whitespace-only note text.
- **FR-013a**: A note MUST NOT exceed 500 characters; the note input MUST enforce this limit and give the user visible feedback as they approach it.
- **FR-013b**: The note input MUST be a multi-line text area (expanding to fit content up to the character limit), not a single-line field, since notes may span more than one line.
- **FR-014**: The Ayah Detail screen MUST include a mnemonic section in its layout that is hidden/not rendered by default, controlled by a single configurable setting so it can be enabled later without further UI rework.
- **FR-015**: The Ayah Detail screen's similar-phrases list MUST show, for each shared phrase found in the current ayah, a distinguishing color marker and the total number of occurrences of that phrase elsewhere in the Quran. Colors MUST be assigned deterministically from a small fixed palette in the list's display order (cycling/wrapping if there are more phrases than palette colors), so the same ayah's phrase list renders with the same colors on every load.
- **FR-016**: Tapping a phrase entry in the similar-phrases list MUST isolate that phrase's highlighting in the ayah text, preserving the existing tap-to-isolate behavior.
- **FR-017**: Favorite status and note content MUST be stored in a writable local store separate from the read-only bundled Quran database, consistent with the app's data architecture.
- **FR-018**: All new user-facing text introduced by this feature (search hints, empty states, favorite/note labels and confirmations) MUST be added as Arabic localized strings rather than hardcoded inline text.

### Key Entities

- **Favorite**: Represents a user's bookmark of a single ayah, identified by surah number + ayah number, with a timestamp of when it was favorited. No content beyond the reference itself.
- **Ayah Note**: Represents a user's personal free-text note (maximum 500 characters) attached to a single ayah, identified by surah number + ayah number. At most one note exists per ayah at a time; saving a new note for an ayah replaces the prior one.
- **Surah (existing)**: Already-modeled entity used for the search filter; no new attributes required, only filtering by its existing Arabic and simple name fields.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can locate a specific surah via search in under 5 seconds, compared to manual scrolling through the full 114-surah list.
- **SC-002**: 100% of favorite and note actions taken by a user persist correctly and are visible again after fully closing and reopening the app.
- **SC-003**: Users can add, edit, and remove a note on an ayah without navigating away from the ayah detail screen.
- **SC-004**: The redesigned ayah detail screen shows phrase occurrence counts and color markers for 100% of ayahs that have shared phrases, matching the reference layout.
- **SC-005**: No existing ayah detail functionality (word highlighting, phrase comparison navigation) regresses as a result of the layout refactor, verified against current behavior.
- **SC-006**: The favorites/notes data layer and diacritic-insensitive search matching are covered by unit tests, and the search field, favorite toggle, note editor (including confirm-delete), and redesigned ayah detail layout are covered by widget tests, before the feature is considered done.

## Assumptions

- The dedicated "Favorites" screen/tab that lists all favorited ayahs is a separate, future feature; this spec covers only the ability to mark/unmark favorites and persist that status so a future favorites screen can read it.
- "Cached locally" for notes means on-device persistent storage (not synced to any account or server), consistent with the app currently having no backend or authentication.
- Search matches against surah name text only; searching by surah number is out of scope for this iteration.
- Search filters the list live as the user types (no separate submit step), matching standard mobile search-field conventions.
- Exactly one note can exist per ayah; there is no support for multiple notes per ayah in this iteration.
- The mnemonic section's content/source (e.g., how mnemonic text is authored or fetched) is out of scope for this spec since the section stays hidden; only the hideable layout placeholder and its on/off setting are required now.
- Favorite and note data are not required to sync across devices in this iteration.
