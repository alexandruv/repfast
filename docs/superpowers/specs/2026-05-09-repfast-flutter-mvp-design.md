# RepFast Flutter MVP Design

## Summary

Build a production-ready Flutter offline MVP for RepFast using the selected single-cockpit flow. The app must open into an active workout, prefill the current lift from previous history, let the user adjust weight and reps with oversized controls, save the set to SQLite, start a rest timer, and show what changed since last time without leaving the screen.

The goal is not a complete fitness platform. The MVP proves the promise: log a set in under 10 seconds, then instantly see what changed.

## Scope

In scope:

- Flutter mobile application under `repfast_app/`.
- SQLite-backed offline persistence.
- Seeded starter data for an active workout and previous comparable session.
- Single cockpit screen for the active workout.
- Oversized weight and reps controls.
- Full-width `LOG SET` primary action.
- Rest timer that starts after a set is logged.
- Previous-set defaults for the current exercise.
- Compact `Today vs last time` comparison strip.
- Workout complete summary card or sheet.
- Domain and widget tests written test-first.

Out of scope for the MVP:

- Signup, login, cloud sync, or remote API calls.
- Social feeds, sharing, coaching content, video content, meal tracking, or broad wellness features.
- Routine builder.
- Full exercise library management.
- Plate calculator, RPE, wearable logging, voice logging, and HealthKit or Health Connect.

## Users and Context

The primary user is a lifter between working sets in a dim gym. They may have shaky hands, one free thumb, sweat or chalk on their hands, and poor signal. The app must assume the user is focused on the next set, not browsing analytics.

## Product Register

Product UI. Design serves the task. Familiar, reliable controls are preferred over novelty. The UI should feel like a serious gym instrument.

## Visual Direction

Use dark gym mode:

- Dark slate and blue-green charcoal surfaces.
- Cyan for current focus and primary action.
- Green for improvement and positive progress.
- Amber only for PR or achievement.
- Strong contrast.
- Large numeric UI.
- Touch targets at least 44px, with core controls closer to 56px.
- No emoji icons.
- No decorative animation.

## Screen Architecture

Use the approved single-cockpit architecture.

### Active Cockpit

Top:

- App identity or compact workout title.
- Current exercise name.
- Set count, for example `Set 4 of 5`.
- Offline/local save status, for example `Saved on device`.

Center:

- Weight control with previous default loaded.
- Reps control with previous default loaded.
- Large plus and minus buttons for each control.
- Optional small previous value hint, for example `Previous: 225 x 5`.

Primary action:

- Full-width `LOG SET` button.
- Disabled only during an active save.
- On success, append the set, advance the state, and start rest timer.

Lower cockpit:

- Rest timer chip or compact ring.
- `Today vs last time` comparison strip with volume delta, best set, PR marker if applicable, and one plain-English takeaway.

### Workout Complete Summary

When the seeded workout is completed, show a summary card or sheet containing:

- Total volume delta versus the previous comparable workout.
- Best set.
- PR marker when the best estimated strength or best set exceeds previous history.
- Plain-English takeaway.

## Data Model

Minimum persisted entities:

- Exercise: id, name, default weight increment, default rep increment.
- WorkoutSession: id, startedAt, completedAt nullable.
- WorkoutSet: id, sessionId, exerciseId, setIndex, weight, reps, completedAt.

Seed data:

- Current session with Bench Press as the active exercise.
- Previous session containing Bench Press history so defaults and comparison work immediately.

## Domain Behavior

- Volume is `weight * reps`, summed across comparable sets.
- Previous default for an exercise uses the most recent completed set for that exercise from a prior session.
- Best set ranks primarily by estimated 1RM, with volume as a secondary display metric.
- Estimated 1RM uses the Epley formula: `weight * (1 + reps / 30)`.
- PR marker appears when the current best estimated 1RM is greater than the previous best estimated 1RM for the same exercise.
- Logging a set starts or restarts the rest timer.
- Local save failure shows an inline retry state without losing the pending set values.

## State Management

Keep a clear separation:

- Pure domain models and calculators.
- Repository interface for workout data.
- SQLite repository implementation.
- Controller or notifier for active workout state.
- Flutter widgets for cockpit presentation.

The domain layer must be testable without Flutter widgets or SQLite.

## Error Handling

- If database initialization fails, show an app-level error with retry.
- If set save fails, keep the current weight and reps visible and show `Set not saved. Retry.`
- If no previous history exists, show neutral comparison copy: `First logged set for this lift.`
- If seeded data creation fails, the app should still show an empty-start state with a retry.

## Accessibility

- Core touch targets must be at least 44px.
- Weight and reps controls need semantic labels.
- Color must not be the only indicator for PR or regression.
- Reduced motion must avoid animated value transitions.
- Text must not overflow at common mobile widths.

## Testing Strategy

Use TDD.

First domain tests:

- Volume calculation.
- Estimated 1RM calculation.
- Previous-set lookup.
- Best-set and PR detection.
- Session comparison.
- Active workout state transition after logging a set.
- Rest timer start behavior.

Then persistence tests:

- Seed data is inserted when the database is empty.
- Logging a set persists a `WorkoutSet`.
- Previous set can be queried by exercise.

Then widget tests:

- Cockpit renders active exercise and previous defaults.
- Plus and minus controls update values.
- `LOG SET` advances set state and shows rest timer.
- Comparison strip updates after logging.
- Save failure keeps values and shows retry.

## Acceptance Criteria

- `flutter test` passes.
- `dart analyze` passes.
- App launches to the active cockpit without signup.
- Active cockpit shows Bench Press, previous defaults, weight/reps controls, log button, rest timer area, and comparison strip.
- Logging a set persists locally and updates the comparison.
- No network access is required for core functionality.
- UI follows the dark gym mode direction and keeps core controls thumb-sized.
