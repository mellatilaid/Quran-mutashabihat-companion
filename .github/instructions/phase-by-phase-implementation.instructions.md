---
description: "Use when implementing tasks from tasks.md or plan.md files with phases. Enforces phase-by-phase execution with explicit approval gates between phases, preventing premature advancement to subsequent phases."
name: "Phase-by-Phase Implementation"
applyTo: "**/tasks.md **/plan.md"
---

# Phase-by-Phase Implementation

**Purpose**: Ensure structured, incremental delivery of multi-phase features by preventing advancement to the next phase until the current phase is explicitly approved.

## Core Workflow

### 1. Identify the Current Phase

- Read the tasks.md or plan.md file to identify the **current phase** (highest numbered phase with incomplete/in-progress tasks).
- Determine the phase's goal, blockers, and completion criteria.
- If the file documents checkpoint criteria (e.g., "Checkpoint: X is working"), use those as the completion definition.

### 2. Complete the Phase

- Work through all tasks in the current phase sequentially or in parallel (as marked with `[P]`).
- Follow task ordering and dependencies exactly as documented.
- Mark tasks complete (`[x]`) as they finish.
- If tests are part of the phase, ensure they pass before considering the phase done.

### 3. Summarize & Request Approval

**Before advancing to the next phase**, provide a summary including:

- ✅ **What was completed**: List the phase's key deliverables (tables created, functions implemented, screens built, tests passing).
- 📋 **Checkpoint verification**: Confirm the phase's documented checkpoint is met (e.g., "Surah search is functional and testable independently").
- ⏭️ **Next phase**: Name the next phase and its goal (e.g., "Phase 4: User Story 2 - Mark an ayah as favorite").
- ❓ **Ready for approval?**: Explicitly ask: *"Phase X is complete. Ready to proceed to Phase Y?"* or similar.

### 4. Wait for Approval

**Do not proceed to the next phase** until the user explicitly approves. Valid approval signals include:

- "Yes, proceed"
- "Approved"
- "Next phase"
- "Continue"
- "Ready for Y"

Approval confirms:
- The phase's deliverables are validated in the running app (manual checks or automated tests pass).
- No blocking issues remain.
- The user is ready for the next phase's scope.

### 5. Move Forward

Once approved, move to the next phase and repeat from step 1.

## Detailed Phase Completion Checklist

Before requesting approval, verify:

- [ ] All tasks in the current phase are marked complete (`[x]`).
- [ ] Any newly created files exist and contain expected code/structure.
- [ ] Repository/provider/model layer changes are tested (unit tests pass if required by the phase).
- [ ] UI wiring is functional (widget tests pass if required, or manual integration has been validated).
- [ ] No `TODO` or `FIXME` comments left in the phase's code.
- [ ] `flutter analyze` reports no new issues introduced by this phase.
- [ ] Localization strings (if added) are generated via `flutter gen-l10n`.
- [ ] The phase's checkpoint criteria (from plan.md or tasks.md) are met.

## Phase Advancement Rules

### ✅ OK to Proceed to Next Phase If:

- Current phase's checkpoint is verified (manual test or auto-test pass).
- All tasks in the current phase are marked `[x]`.
- No blocking bugs or unmet dependencies exist.
- User explicitly approves.

### ❌ Do NOT Proceed If:

- Any task in the current phase remains incomplete.
- Tests for the phase fail.
- Checkpoint criteria are not met.
- User has not explicitly approved.
- Blocking dependency tasks from earlier phases are still incomplete.

## Example Approval Checkpoint

**Phase 2: Foundational (Blocking Prerequisites)** checkpoint:

> "Checkpoint: `ayah_notes` table exists with a working migration path, `UserDataRepository` has full note CRUD, `normalizeForSearch` is available, and both new providers compile. User story phases can now begin."

When requesting approval:

> ✅ **Phase 2 Complete**
> - `ayah_notes` table created with migration in `_onUpgrade` ✓
> - `UserDataRepository` CRUD methods (get/save/delete) verified via unit tests ✓
> - `normalizeForSearch` tested with diacritics and case-insensitivity ✓
> - New providers (`noteProvider`, `mnemonicSectionEnabledProvider`) compile ✓
> - `flutter analyze` clean ✓
>
> **Phase 3 (User Story 1 - Surah Search)** is ready to start.
>
> **Proceed to Phase 3?**

## Special Cases

### Parallel Tasks Within a Phase

Tasks marked `[P]` can be implemented simultaneously by different developers/branches, but the phase is not complete until all (parallel and sequential) tasks are done.

### Dependent Phases

Some phases explicitly depend on earlier phases (e.g., Phase 6 depends on Phases 4 and 5). Ensure all dependencies are complete and approved before starting a dependent phase.

### Unfinished Work in a Phase

If a phase reveals unexpected work or bugs:
1. Add the issue as a new task in the phase.
2. Complete it before requesting approval.
3. Do not skip to the next phase; stay in the current phase until all work is done.

## Benefits

- **Predictable progress**: Each phase is a self-contained, verifiable increment.
- **Early feedback**: Approval gates catch issues and misunderstandings before they compound across phases.
- **Clear ownership**: Checkpoints define what "done" means, reducing scope creep.
- **Team coordination**: Explicit gates allow parallel work to converge safely and team reviews to happen at logical breakpoints.
