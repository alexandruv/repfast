---
version: alpha
name: RepFast Yellow Iron
description: Dark yellow-and-black strength logging interface for fast offline workout capture.
colors:
  ink: "#171205"
  ink-deep: "#0B0904"
  surface: "#151207"
  surface-raised: "#211B0E"
  surface-control: "#050504"
  line: "#5A4B17"
  line-strong: "#D7AF11"
  text: "#F3EFE4"
  muted: "#B8AE97"
  dim: "#867E69"
  action: "#FFD21A"
  action-pressed: "#E0AF12"
  success: "#79D47A"
  error: "#D95B48"
typography:
  display-xl:
    fontFamily: Inter, ui-sans-serif, system-ui, sans-serif
    fontSize: 84px
    fontWeight: 950
    lineHeight: 0.9
    letterSpacing: 0
  headline-lg:
    fontFamily: Inter, ui-sans-serif, system-ui, sans-serif
    fontSize: 52px
    fontWeight: 950
    lineHeight: 0.94
    letterSpacing: 0
  headline-md:
    fontFamily: Inter, ui-sans-serif, system-ui, sans-serif
    fontSize: 26px
    fontWeight: 950
    lineHeight: 1.08
    letterSpacing: 0
  body-lg:
    fontFamily: Inter, ui-sans-serif, system-ui, sans-serif
    fontSize: 18px
    fontWeight: 500
    lineHeight: 1.48
    letterSpacing: 0
  body-md:
    fontFamily: Inter, ui-sans-serif, system-ui, sans-serif
    fontSize: 16px
    fontWeight: 500
    lineHeight: 1.5
    letterSpacing: 0
  label-md:
    fontFamily: Inter, ui-sans-serif, system-ui, sans-serif
    fontSize: 13px
    fontWeight: 950
    lineHeight: 1
    letterSpacing: 0
  label-sm:
    fontFamily: Inter, ui-sans-serif, system-ui, sans-serif
    fontSize: 12px
    fontWeight: 950
    lineHeight: 1
    letterSpacing: 0
  numeric-lg:
    fontFamily: Inter, ui-sans-serif, system-ui, sans-serif
    fontSize: 42px
    fontWeight: 950
    lineHeight: 1
    letterSpacing: 0
    fontFeature: "'tnum' 1"
rounded:
  sm: 6px
  md: 8px
  lg: 22px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 12px
  lg: 16px
  xl: 22px
  xxl: 34px
  section: 96px
  max-width: 1180px
components:
  eyebrow:
    backgroundColor: "{colors.action}"
    textColor: "{colors.ink}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.sm}"
    padding: 5px 8px
  button-primary:
    backgroundColor: "{colors.action}"
    textColor: "{colors.ink}"
    typography: "{typography.label-md}"
    rounded: "{rounded.sm}"
    height: 64px
    padding: 0 16px
  button-secondary:
    backgroundColor: "{colors.ink-deep}"
    textColor: "{colors.action}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.sm}"
    height: 64px
    padding: 0 16px
    borderColor: "{colors.line-strong}"
  cockpit-panel:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.text}"
    rounded: "{rounded.lg}"
    padding: 22px
    borderColor: "{colors.line}"
  numeric-control:
    backgroundColor: "{colors.surface-control}"
    textColor: "{colors.text}"
    typography: "{typography.numeric-lg}"
    rounded: "{rounded.sm}"
    height: 92px
    borderColor: "{colors.line}"
  status-note:
    backgroundColor: "{colors.surface-raised}"
    textColor: "{colors.text}"
    rounded: "{rounded.sm}"
    padding: 14px
    borderColor: "{colors.line}"
---

# RepFast Design System

## Overview

RepFast is a fast, focused, hard-wearing strength logging product. The UI should feel like a serious gym instrument used between heavy sets, not a wellness feed, analytics dashboard, or social fitness app.

The current design direction is a yellow-and-black, low-light product interface. It is inspired by durable training gear, black plates, rubber flooring, bench vinyl, and utilitarian labels. The core emotional target is controlled intensity: clear enough for shaky hands, sharp enough to feel purpose-built.

Recent implementation changes moved the page from a cyan gym-tech style to this yellow-and-black system. The hero now contains a working RepFast logging cockpit, the product image was replaced with a context shot that shows the actual logger UI, the under-construction tape decoration was removed, and section badges were corrected to compact dark-on-yellow labels.

The first screen must prove the product promise: open the app, adjust weight or reps, log the set, see saved-on-device feedback, and keep rest and comparison data visible.

## Colors

The palette uses near-black surfaces, warm yellow action color, and muted gym-floor neutrals.

- **Ink (`#171205`):** Primary dark identity color. Use for text on yellow, brand marks, and the deepest UI surfaces.
- **Ink Deep (`#0B0904`):** Page background and deepest shadows. Never use pure black.
- **Surface (`#151207`):** Main cockpit panel surface.
- **Surface Raised (`#211B0E`):** Notes, subtle grouped areas, and lifted controls.
- **Surface Control (`#050504`):** Numeric input wells and high-focus control interiors.
- **Line (`#5A4B17`):** Low-light borders and dividers.
- **Line Strong (`#D7AF11`):** High-emphasis yellow border.
- **Text (`#F3EFE4`):** Primary readable text, tinted warm rather than pure white.
- **Muted (`#B8AE97`):** Secondary copy, helper text, and labels.
- **Dim (`#867E69`):** Low-priority labels and metadata.
- **Action (`#FFD21A`):** Primary action, section badges, current focus, and key product signal.
- **Action Pressed (`#E0AF12`):** Pressed or active yellow state.
- **Success (`#79D47A`):** Positive comparison and saved confirmation.
- **Error (`#D95B48`):** Save failure or retry state, always paired with text.

Yellow must not be used as broad decoration when it competes with the primary action. Dark text on yellow must use `#171205` or an equivalent near-black, never muted gray.

## Typography

The current implementation uses Inter/system sans for all UI text. This is acceptable for product clarity, but the open typography improvement is to add a condensed industrial display face for major hero and section headlines while keeping system sans for controls.

- **Display:** Uppercase, heavy, compact, used only for the hero headline and large marketing statements.
- **Headlines:** Heavy and uppercase, but smaller than display. Use for section titles and app screen titles.
- **Body:** Short, practical, and line-limited. Body copy should explain the product without motivational clutter.
- **Labels:** Uppercase, high-weight, and short. Use labels for scan speed: `WEIGHT`, `REPS`, `SET 4/5`, `REST TIMER`.
- **Numerics:** Large, tabular, and visually dominant. Weight, reps, rest time, and deltas must be easier to read than their labels.

Do not use negative letter spacing. Do not set long prose in all caps.

## Layout

RepFast is mobile-first and thumb-first, but the landing page uses a two-column desktop hero to show both the product cockpit and product-in-context image.

- Use a max content width of 1180px.
- On desktop, the hero should balance product proof on the left with a supporting product image on the right.
- On mobile, the interactive cockpit should stay before the supporting product image.
- Keep the active logging cockpit as one primary surface, not a collection of unrelated cards.
- Group weight and reps as stacked fields, matching the phone mockup and generated product image.
- Keep the primary `LOG SET` button full width and at least 64px high in product surfaces.
- Rest timer, volume delta, and storage mode should remain visible in the cockpit.

Avoid broad full-width yellow bars for labels. Section badges should be compact and content-width.

## Elevation & Depth

Depth is created through tonal layers, borders, and controlled shadow, not glass effects.

- Page background: deep ink with subtle texture embedded in the background only.
- Panels: dark raised surfaces with yellow-brown borders.
- Controls: darker wells inside panels.
- Product image: one thin yellow border, restrained shadow, no hazard tape overlays.
- Floating proof strip: allowed only when it reinforces a real product state such as previous set loaded.

Do not use foreground blend overlays that wash out text or labels. Do not use decorative glassmorphism.

## Shapes

The shape language is compact and engineered.

- Small controls and badges use 6px radius.
- Buttons use 6px radius.
- Phone-like cockpit panels use 22px radius.
- Rings and timer progress indicators may use full radius.
- Do not mix pill-shaped controls with hard industrial controls on the same surface unless the element is genuinely circular, such as a timer ring.

## Components

### Hero Logging Cockpit

The hero cockpit is the primary proof of the product. It must remain consistent with the mobile app screens and product image.

Required structure:

- Top row: `RepFast` and `Set 4/5`.
- Title: current exercise, such as `Bench Press`.
- Weight field: label, large value, unit, minus and plus steppers.
- Reps field: label, large value, minus and plus steppers.
- Primary action: `LOG SET`.
- Status note: previous default or saved-on-device state.
- Outcome stats: rest timer, volume delta, and storage mode.

Do not add internal demo controls like `Simulate offline error` to the visible hero.

### Buttons

Primary buttons are yellow with dark text. Secondary buttons are dark with yellow text and a yellow border. Button text should be short, uppercase, and command-oriented.

Primary action examples:

- `LOG SET`
- `SEE SCREENS`

Secondary action examples:

- `GYM SCENARIO`
- `RETRY SAVE` when shown in an actual error state

### Numeric Steppers

Numeric steppers use a dark control well, large numeric value, and two square buttons. Keep the hit target at least 44px, preferably 56px for gym use.

### Status Notes

Status notes must be readable and plain.

Examples:

- `Previous: 225 lb x 5. Ready offline.`
- `Saved on device: 225 lb x 6. Rest timer started.`
- `Set not saved. Retry.` when an error state is intentionally shown.

### Section Badges

Badges are compact yellow labels with dark text. They should never stretch full width.

Correct:

- `ROADMAP`
- `THE GAP`
- `PRODUCT IDEA`

Incorrect:

- Full-width yellow bars with muted gray text.

### Product Imagery

Use `assets/repfast-hero-product.png` for the current hero image. It shows the actual RepFast-style logger in context: bench, loaded barbell, black plates, yellow log button, and saved-on-device state.

Avoid generic fitness analytics imagery, teal/cyan dashboards, fake chart-heavy screens, construction tape, and stock wellness visuals.

## Do's and Don'ts

- Do make the log loop visible before abstract product claims.
- Do keep `LOG SET` as the clearest action on any active workout surface.
- Do use yellow for primary action, current focus, and compact section labels.
- Do use green only for positive progress or saved confirmation.
- Do make offline feel normal, not exceptional.
- Do keep product copy terse and gym-floor practical.
- Do verify yellow label contrast after any background or overlay change.
- Don't use full-width badge bars unless they are intentionally section dividers.
- Don't place internal demo or QA controls in the public hero.
- Don't use teal/cyan analytics imagery in the yellow-black direction.
- Don't add social, coaching, meal, or wellness UI patterns.
- Don't use foreground overlays, blend modes, or textures that reduce text contrast.
- Don't use decorative hazard tape or construction-site graphics.
