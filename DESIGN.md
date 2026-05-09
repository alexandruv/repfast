# Design

## Product Surface

RepFast is a dark, task-first mobile product UI. The default surface is an active workout cockpit for a lifter in a dim gym, between heavy sets, using one thumb under time pressure.

## Color

Use a restrained dark palette with functional accents.

- App background: near-black slate, not pure black.
- Primary surface: dark blue-green charcoal.
- Secondary surface: slightly lifted slate.
- Border: cool muted slate with enough separation in low light.
- Text: tinted off-white for primary labels, blue-gray for secondary labels.
- Primary action/current focus: cyan.
- Positive progress: green.
- Achievement/PR: limited amber.
- Error: muted red with text/icon support.

Do not use accent color as decoration. Cyan is for the primary action and current focus. Green is for measured progress. Amber is reserved for PR or achievement.

## Typography

Use the platform/system sans stack through Flutter defaults, tuned with explicit text styles. Numeric values use tabular figures where available and must be visibly larger than labels.

- Screen title: compact, high-weight, not hero-sized.
- Active weight and reps: large numeric display.
- Labels: uppercase or small high-weight labels only where they speed scanning.
- Body/help copy: short, practical, never paragraph-heavy during the workout.

## Layout

Mobile-first and thumb-first.

- The active cockpit is one primary screen.
- Exercise identity and set progress sit at the top.
- Weight and reps controls dominate the center.
- The log action is full-width and at least 56px tall.
- Rest timer and comparison are visible without leaving the screen.
- Summary can appear as a bottom sheet or lower card after workout completion.

Avoid nested cards. Use clear panels only when they group controls that are manipulated together.

## Components

- Active workout cockpit
- Numeric stepper control for weight
- Numeric stepper control for reps
- Primary log button
- Rest timer chip or ring
- Compact comparison strip
- Workout complete summary card
- Inline error/retry message for local save failure

All interactive controls must have default, pressed, focused, disabled, and error or retry states where relevant.

## Motion

Motion is functional only.

- Button press feedback should be immediate.
- Rest timer updates should be calm and readable.
- Comparison updates can use a short value transition, disabled under reduced motion.
- No decorative page-load choreography.

## Copy

Use terse gym-floor copy.

- Primary action: `LOG SET`
- Offline state: `Saved on device`
- Previous default hint: `Previous: 225 x 5`
- Comparison title: `Today vs last time`
- Positive takeaway example: `You added one rep at the same weight.`
- Save failure: `Set not saved. Retry.`
