# Worthly Design Guidelines

Worthly uses a compact, native iOS design language for a local-first asset map. Design decisions should make scattered money easier to scan, not make the app feel like a marketing page.

## Layout Grid

Use a 4pt spacing grid. All custom spacing should be a multiple of 4.

```text
4   xxs   Tiny label/detail gap
8   xs    Compact vertical padding
12  sm    Card inner spacing and close content groups
16  md    Default screen margin and row icon gap
20  lg    Larger content separation
24  xl    Major group spacing and large rounded form radius
28  xxl   Editor bottom padding
32  xxxl  Large top spacing and onboarding rhythm
40        Bottom page padding above the tab bar
```

Standard screen padding:

- Horizontal screen padding: 16
- Top content after large navigation title: 8
- Bottom page padding: 40
- Major vertical section gap: 12 or 16

## Components

Summary cards:

- Use `WorthlySummaryCard`.
- Default inner padding: 12.
- Use 16 padding for instructional cards and onboarding content.
- Use `WorthlyCardBackground` for fill, stroke, and shadow.

Section headers:

- Use `WorthlySectionHeader`.
- Title font: headline.
- Optional amount uses secondary color and monospaced digits.
- Place directly above the related rows with an 8pt group rhythm.

Empty states:

- Use `WorthlyEmptyStateCard`.
- Include one clear icon, title, short message, and an action only when the action is the natural next step.
- Avoid explaining the whole app inside an empty state.

Editor forms:

- Use `WorthlyFullScreenEditorContainer`.
- Editors are full-screen for focused add/edit tasks.
- Header button size: 44.
- Editor horizontal padding: 16.
- Editor content top padding: 20.
- Use a checkmark for save/confirm and xmark/back for exit.

## Navigation

- Overview `+` opens a menu because the user can add different object types there.
- Assets `+` opens Add Asset.
- History `+` opens Add Transaction.
- Planning should not show a `+` until there is a real planning-add flow.
- Settings should not have a `+`.

## Onboarding

First-run onboarding is a setup flow, not an intro carousel.

Required core flow:

1. Add first account.
2. Add liability or confirm no liabilities.
3. Add investment or skip.
4. Add first transaction or add it later.
5. Show Overview.

The user should leave onboarding with enough data for a meaningful dashboard.

## Typography

- Large navigation title: native SwiftUI large title.
- Main card amount: title2 bold with monospaced digits.
- Secondary metric amount: title2 bold.
- Section header: headline.
- Row body: body.
- Helper copy: subheadline or caption, secondary color.

Do not scale font size using viewport width. Let Dynamic Type drive scaling.

## Color And Contrast

- Prefer semantic colors: primary, secondary, system red, system green, system blue.
- Do not rely on color alone for meaning; keep plus/minus signs and labels.
- Chart colors must adapt for light mode, dark mode, and increased contrast.
- Avoid opacity-based disabled text when semantic secondary color is enough.

## Accessibility

- Dynamic Type must not clip essential text.
- Rows should switch to vertical value-below layouts at accessibility sizes.
- Amount text should wrap or reflow when needed instead of shrinking into unreadability.
- Important summary cards need meaningful accessibility labels.
- Touch targets should be at least 44pt.
