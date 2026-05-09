# RepFast Handoff

Last updated: 2026-05-09

## Current Status

RepFast now has a Flutter offline MVP in `repfast_app/` and the work is pushed to GitHub `main`.

Latest pushed commit:

```text
b25176b Add exercise selector
```

Remote:

```text
https://github.com/alexandruv/repfast.git
```

The product is still intentionally a single active workout cockpit, not a multi-screen finished app.

## What Exists

- Static product pitch site in `repfast-site/`.
- Flutter app in `repfast_app/`.
- Offline SQLite repository with starter exercise/session/set data.
- Active cockpit screen for fast set logging.
- Dark Gym Mode theme and large touch-first controls.
- Weight/reps steppers.
- `LOG SET` action that persists locally.
- Rest timer countdown from `1:00` after a set is logged.
- Comparison strip showing today vs last time.
- Settings bottom sheet with `lb` / `kg` display preference.
- Tappable exercise title with bottom-sheet exercise selector.

Starter exercises:

- Bench Press
- Squat
- Deadlift
- Overhead Press
- Barbell Row

## Core Product Promise

The MVP is built around:

```text
Open, lift, log, compare.
```

The app avoids signup, social feed, coaching clutter, and cloud requirements. It should remain usable in a gym with one hand and poor signal.

## Important Implementation Notes

### Architecture

Domain:

- `repfast_app/lib/src/domain/models.dart`
- `repfast_app/lib/src/domain/calculators.dart`
- `repfast_app/lib/src/domain/comparison.dart`

Persistence:

- `repfast_app/lib/src/data/workout_repository.dart`
- `repfast_app/lib/src/data/sqlite_workout_repository.dart`

Application state:

- `repfast_app/lib/src/application/active_workout_controller.dart`

UI:

- `repfast_app/lib/src/ui/repfast_app.dart`
- `repfast_app/lib/src/ui/screens/active_cockpit_screen.dart`
- `repfast_app/lib/src/ui/theme.dart`
- `repfast_app/lib/src/ui/weight_unit.dart`
- `repfast_app/lib/src/ui/widgets/*`

### Data Model Limits

- Weight is currently stored internally as pounds.
- The `kg` setting is a UI conversion layer, not a persisted user preference yet.
- The active exercise selection is in controller/UI state only. It is not persisted across app launches yet.
- Rest timer records `restStartedAt` in `ActiveWorkoutState`, but rest duration insights are not built yet.
- SQLite seeds starter data only when the exercise table is empty.

### Current UX Behavior

- App opens directly into the cockpit.
- Exercise title is tappable and opens the exercise selector.
- Selecting an exercise reloads defaults for that exercise.
- Bench Press has seeded previous data, so it defaults to `225 x 5`.
- Other starter exercises currently fall back to `45 x 5`.
- Logging a set starts rest countdown at `Rest 1:00`.
- At zero the chip reads `Rest done`.

## Verification

Most recent verification before this handoff:

```bash
cd repfast_app
dart analyze
flutter test
```

Expected current result:

- `dart analyze`: no issues
- `flutter test`: all tests pass

Recent full test count after exercise selector: `32` tests.

Credential scans were run before pushes using patterns for common sensitive values. No credential values were found.

## Recent Commit Timeline

```text
b25176b Add exercise selector
11efc84 Add rest countdown timer
9eb4772 Add weight unit settings
707d714 Polish RepFast MVP
3c18744 Harden active cockpit UI
1cf6d7f Add active workout cockpit UI
e090870 Harden RepFast UI component layout
3aae3b1 Add RepFast UI components
a06510d Advance set index after refresh failure
94fd855 Harden active workout saves
8d5c173 Add active workout controller
168a9fa Harden SQLite repository
```

## Good Next Steps

1. Persist user settings:
   - Save `lb` / `kg`.
   - Save last selected exercise.

2. Improve exercise data:
   - Add previous seeded data for Squat/Deadlift/Overhead Press/Rows.
   - Add exercise management later, but keep it out of the cockpit.

3. Build rest insights:
   - Store rest duration between sets.
   - Show average rest, longest rest, and whether performance improves after longer/shorter rests.

4. Add session/history view:
   - Keep cockpit first.
   - Add summary/history as secondary access, not the launch screen.

5. Run on a simulator/device:
   - Verify actual iOS/Android rendering.
   - Check bottom sheets, tap targets, keyboard-safe layout, and dark gym contrast.

## Caution

The code is on branch `codex/repfast-flutter-mvp` locally, but it has been pushed directly to `origin/main`. Before new work, run:

```bash
git fetch origin
git status -sb
git log --oneline --decorate --max-count=5
```

Avoid committing credentials. The user previously pasted an OpenAI credential in chat; do not write it to files, env examples, docs, or commit history.
