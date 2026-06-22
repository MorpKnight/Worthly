# Worthly

Worthly is a local-first iOS asset map for people whose money is spread across bank accounts, e-wallets, investments, liabilities, and daily transactions.

The app helps users answer a simple question: **where is my money, what do I owe, and am I on track toward my target?**

> Worthly is a prototype and learning project. It is not financial advice, accounting software, or production financial infrastructure.

## Highlights

- Local-first SwiftUI app with no backend, auth, cloud sync, or bank integration.
- First-run onboarding that starts from an empty money map.
- Overview dashboard for net worth, cashflow, planning preview, setup actions, and recent transactions.
- Assets page for liquid accounts, investments, liabilities, and asset allocation.
- Planning page with target-readiness projection, recurring income, recurring expenses, investment returns, and liability payments.
- History page with transaction filters and add/edit transaction flows.
- Safe dummy-data mode that preserves real local data.
- Full-screen editor modals for focused add/edit tasks.
- Dynamic Type and contrast-oriented accessibility pass.
- Design guidelines for spacing, layout, navigation, typography, color, and reusable components.

## Product Direction

Worthly is intentionally not a full budgeting or accounting system yet. The current MVP focuses on clarity:

- Show scattered assets in one place.
- Separate assets from liabilities.
- Make first setup lightweight.
- Keep private financial data on device.
- Help users see whether their current money map is enough for a target.

## Screens

- **Overview**: net worth, cashflow, planning preview, guided setup, recent transactions, and Settings entry.
- **Planning**: target status, projected net worth, gap/surplus, recurring assumptions, and projection horizon.
- **Assets**: accounts, investments, liabilities, and allocation chart.
- **History**: income, expense, and transfer records.
- **Settings**: dummy data toggle, local data note, and reset local data.

## Getting Started

### Requirements

- Xcode 26.5 or newer
- iOS 26.5 SDK
- SwiftUI

### Build

```sh
xcodebuild -project Worthly.xcodeproj \
  -scheme Worthly \
  -destination generic/platform=iOS \
  -derivedDataPath ./.DerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

### Run Tests

Use an available iOS simulator on your machine. For example:

```sh
xcodebuild -project Worthly.xcodeproj \
  -scheme Worthly \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath ./.DerivedData \
  CODE_SIGNING_ALLOWED=NO test
```

If your simulator name is different, run:

```sh
xcrun simctl list devices available
```

Then replace the destination name.

## Project Structure

```text
Worthly/
  App/                  App entry point and tab shell
  Assets.xcassets/      App icon, accent color, and asset catalog
  Features/
    Overview/           Overview dashboard and setup card
    Assets/             Assets screen, allocation chart, and asset editors
    Planning/           Planning screen, projection output, and planning editors
    History/            History screen, filters, and transaction editors
    Onboarding/         First-run setup flow
    Settings/           Preferences, dummy data toggle, and reset action
  Shared/
    Components/         Reusable SwiftUI components, spacing, colors, accessibility helpers
    Data/               Finance store, persistence, projection engine, and sample data
    Formatting/         IDR, date, and display formatting helpers
    Models/             Finance domain models

WorthlyTests/           Unit tests for planning projection behavior
```

The Xcode project uses a file-system-synchronized root group, so new Swift files under `Worthly/` are picked up without manual project file edits.

## Data And Privacy

- Data is stored locally as JSON.
- Fresh installs start empty.
- Dummy data is opt-in from Settings.
- Enabling dummy data preserves the current user snapshot.
- Disabling dummy data restores the preserved user snapshot.
- Reset local data clears the local snapshot and returns to onboarding.

Worthly currently has no backend, no authentication, no cloud sync, and no bank integration.

## Planning Model

The current Planning V1 engine is intentionally simple:

- Projects month by month from the current money map.
- Includes recurring income and recurring expenses.
- Includes fixed investment returns while investments are active.
- Splits liability payments into interest and principal.
- Computes projected net worth, gap/surplus to target, and extra monthly surplus needed when behind.

Not included yet:

- Investment tax.
- Compounding.
- Scenario comparison.
- Irregular income/expenses.
- Production-grade financial advice.

## Design Notes

- [DESIGN_GUIDELINES.md](DESIGN_GUIDELINES.md) documents Worthly spacing, layout, navigation, typography, color, and accessibility agreements.
- [CBL_FOUNDATION.md](CBL_FOUNDATION.md) documents the Challenge Based Learning foundation, problem framing, validation plan, and reflection notes.

## Roadmap

- Delete flows for assets, liabilities, and transactions.
- Category and account management.
- History search.
- Better investment return, tax, and maturity assumptions.
- More complete liability and amortization controls.
- More formal VoiceOver audit.
- More store, persistence, and transaction-balance tests.
- User validation with target participants.
- Possible migration from JSON persistence to SwiftData.

## Contributing

This project is public, but it is still early. Contributions are welcome when they keep the app focused on its current direction: local-first asset clarity.

Good contribution areas:

- Accessibility improvements.
- Test coverage.
- UX writing and flow clarity.
- Small, well-scoped SwiftUI refactors.
- Planning model correctness.
- Design documentation.

Before opening a larger change, consider starting with an issue or short proposal so the scope stays aligned.

## Development Notes

- Keep custom spacing on the 4pt grid.
- Prefer shared components in `Worthly/Shared/Components/`.
- Keep finance data local unless the product direction changes.
- Avoid adding bank integration, auth, or backend features before user validation supports that scope.
- Preserve Dynamic Type and contrast behavior when changing UI.

## License

No license file has been added yet. Until a license is chosen, reuse rights are not explicitly granted.
