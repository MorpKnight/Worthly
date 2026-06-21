# Worthly

Worthly is a local-first iOS asset map for people whose money is spread across banks, e-wallets, investments, liabilities, and daily transactions.

The app is currently a SwiftUI prototype focused on clarity: start from an empty money map, add the places where money lives, track liabilities separately, and use local-only data to understand net worth, cashflow, history, and simple planning assumptions.

## What It Solves

Worthly is not trying to be a full accounting system yet. The first product direction is simpler:

- Help people see where their assets are.
- Separate assets from liabilities clearly.
- Make scattered accounts easier to scan.
- Keep setup lightweight and local-first.
- Avoid bank integration, cloud sync, accounts, or backend complexity for now.

## Current Features

- Four-tab SwiftUI app: Overview, Planning, Assets, and History, with Settings opened from Overview.
- First-run onboarding flow for adding the first account, liability status, optional investment, and optional first transaction.
- Local JSON persistence with backward-compatible decoding.
- Safe `Use dummy data` toggle in Settings, reached from Overview, that preserves real local data.
- Overview dashboard with net worth, cashflow, planning preview, setup actions, and recent transactions.
- Assets page with liquid accounts, investments, liabilities, and a contrast-aware allocation donut chart.
- Add and edit flows for accounts, investments, and liabilities.
- Planning page with editable salary, investment return, debt, and projection horizon assumptions.
- History page with transaction filters and add/edit transaction flows.
- Transfer-aware transaction model with source and destination accounts.
- Full-screen editor modals for focused add/edit tasks.
- Dynamic Type and contrast accessibility pass across shared UI components and main screens.
- App icon assets for default, dark, and tinted appearances.
- Design guideline document for Worthly spacing, layout, navigation, and component rules.

## Project Structure

```text
Worthly/
  App/                  App entry point and tab shell
  Assets.xcassets/      App icon, accent color, and asset catalog
  Features/
    Overview/           Overview dashboard and setup card
    Assets/             Assets screen, allocation chart, and asset editors
    Planning/           Planning screen, assumptions, and planning editors
    History/            History screen, filters, and transaction editors
    Settings/           Preferences, dummy data toggle, and reset action
  Shared/
    Components/         Reusable SwiftUI components, spacing, colors, accessibility helpers
    Data/               Finance store, persistence wrapper, and sample data
    Formatting/         IDR, date, and display formatting helpers
    Models/             Finance domain models
```

The Xcode project uses a file-system-synchronized root group, so new Swift files under `Worthly/` are picked up without manual project file edits.

## Requirements

- Xcode 26.5 or newer
- iOS 26.5 SDK
- SwiftUI

## Build

```sh
xcodebuild -project Worthly.xcodeproj \
  -scheme Worthly \
  -destination generic/platform=iOS \
  -derivedDataPath ./.DerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

If the sandboxed build cannot access CoreSimulator or asset catalog services, rerun the same command in a normal local terminal.

## Data Model Notes

- Data is stored locally as JSON.
- Fresh installs start empty.
- Dummy data is opt-in from Settings, opened from Overview.
- Enabling dummy data preserves the current user snapshot.
- Disabling dummy data restores the preserved user snapshot.
- Reset local data clears the local snapshot and returns the app to empty setup.

## Status

Worthly is still a prototype and should not be treated as production financial software.

Planned next improvements:

- Delete flows for assets, liabilities, and transactions.
- Category and account management.
- Search implementation in History.
- Better investment return, tax, and maturity assumptions.
- More complete debt amortization behavior.
- More formal accessibility and VoiceOver audit.
- Possible migration from JSON persistence to SwiftData.

## Privacy

Worthly currently has no backend, no auth, no cloud sync, and no bank integration. Data stays on the device unless the implementation changes in a future milestone.
