<div align="center">
  <img src="Worthly/Assets.xcassets/AppIcon.appiconset/WorthlyIcon-Any.png" alt="Worthly app icon" width="96" />
  <h1>Worthly</h1>
  <p><strong>A local-first iOS money map for clearer net worth and target planning.</strong></p>

  ![Platform: iOS](https://img.shields.io/badge/platform-iOS_26.5%2B-0A84FF?style=flat-square&logo=apple&logoColor=white)
  ![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-F05138?style=flat-square&logo=swift&logoColor=white)
  ![Status: Prototype](https://img.shields.io/badge/status-prototype-6E56CF?style=flat-square)
</div>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#getting-started">Getting started</a> •
  <a href="#project-structure">Project structure</a> •
  <a href="#data-and-privacy">Data and privacy</a> •
  <a href="#planning-model">Planning model</a>
</p>

Worthly helps people see where their money lives across bank accounts, e-wallets, cash, investments, and liabilities. It brings those pieces together into one readable view so users can answer three questions:

1. What do I have right now?
2. What reduces my real net worth?
3. Am I moving toward my target?

> [!WARNING]
> Worthly is a prototype and learning project. It is not financial advice, accounting software, or production financial infrastructure.

## Features

- Guided first-run setup that starts from an empty money map.
- Current net worth calculated from liquid assets, investments, and liabilities.
- Optional dummy-data mode for exploring the app without replacing the user snapshot.
- Full-screen add and edit flows for accounts, investments, liabilities, and transactions.
- IDR-focused formatting with readable, monospaced financial amounts.
- Dynamic Type, contrast-aware chart colors, accessible labels, and 44pt touch targets.
- Local SwiftUI architecture with no backend, authentication, cloud sync, or bank integration.

## App areas

| Area | Purpose |
| --- | --- |
| **Overview** | Shows current net worth, monthly cashflow, planning preview, guided setup actions, recent transactions, and quick-add actions. |
| **Planning** | Projects target readiness from recurring income, recurring expenses, investment returns, liability payments, and a selected horizon. |
| **Assets** | Separates liquid accounts, investments, and liabilities, with totals and a liquid-assets-versus-investments allocation chart. |
| **History** | Records income, expenses, and transfers with filters, month summaries, date grouping, and add/edit flows. |
| **Onboarding** | Walks through the minimum setup: first account, liability status, optional investment, and first transaction. |
| **Settings** | Provides currency/category placeholders, local-data information, dummy-data mode, and reset controls. |

## Getting started

### Requirements

- macOS with Xcode 26.5 or newer
- iOS 26.5 SDK
- An iPhone or iPad simulator or device for running the app

The project has no external package dependencies.

### Clone

```sh
git clone https://github.com/MorpKnight/Worthly.git
cd Worthly
```

### Build

Build without code signing:

```sh
xcodebuild -project Worthly.xcodeproj \
  -scheme Worthly \
  -destination generic/platform=iOS \
  -derivedDataPath ./.DerivedData \
  CODE_SIGNING_ALLOWED=NO build
```

### Run tests

Use an available iOS simulator. Replace `iPhone 17` if that device is not installed:

```sh
xcodebuild -project Worthly.xcodeproj \
  -scheme Worthly \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath ./.DerivedData \
  CODE_SIGNING_ALLOWED=NO test
```

List available simulator destinations with:

```sh
xcrun simctl list devices available
```

## Project structure

```text
Worthly/
  App/                  App entry point and tab shell
  Assets.xcassets/      App icon and accent color
  Features/
    Onboarding/         First-run money-map setup
    Overview/           Net worth dashboard and guided actions
    Assets/             Accounts, investments, liabilities, and allocation chart
    Planning/           Projection output and planning editors
    History/            Transaction list, filters, and editors
    Settings/           Preferences, dummy data, and reset actions
  Shared/
    Components/         Reusable SwiftUI layout, amount, and accessibility components
    Data/               Finance store, persistence, projection engine, and sample data
    Formatting/         IDR, date, and display formatting helpers
    Models/             Finance domain models

WorthlyTests/           XCTest coverage for planning and finance behavior
DESIGN_GUIDELINES.md    Spacing, layout, navigation, typography, and accessibility agreements
Worthly.xcodeproj/      Xcode project and test target
```

The Xcode project uses file-system-synchronized root groups, so Swift files added under `Worthly/` and `WorthlyTests/` are picked up automatically.

## Data and privacy

- Finance data is stored locally as JSON in the app's Application Support directory.
- A fresh install starts with an empty money map.
- Dummy data is opt-in. Enabling it preserves the current user snapshot; disabling it restores that snapshot.
- Resetting local data clears the saved snapshot and returns to onboarding.
- Worthly currently stores no data in a backend and does not connect to banks or financial providers.

The app treats account balances and transaction history as separate concepts: the money map starts from current balances, while History provides cashflow and activity context. Planning uses saved balances, investments, liabilities, and recurring assumptions rather than trying to reconstruct a financial ledger.

## Planning model

The current Planning V1 engine is intentionally simple and educational:

- Starts with liquid assets plus investment principal minus remaining liabilities.
- Projects month by month from the reference date through the selected horizon.
- Adds future recurring income and recurring expenses on their scheduled dates.
- Adds fixed monthly investment coupons while an investment is active.
- Calculates liability payments by splitting interest and principal using the saved annual rate and remaining balance.
- Reports projected net worth, target gap or surplus, target readiness, and the extra monthly surplus needed when behind.

The model does not yet include taxes, inflation, market-price changes, compounding, irregular income or expenses, scenario comparison, or production-grade financial guidance.

## Design notes

Worthly follows a compact native iOS design language that prioritizes scanability and readability over decoration. The shared agreements for spacing, layout, navigation, typography, color, Dynamic Type, contrast, and touch targets are documented in [DESIGN_GUIDELINES.md](DESIGN_GUIDELINES.md).

## Roadmap

- Delete flows for accounts, investments, liabilities, and transactions.
- Category and account management.
- History search.
- More complete investment return, tax, and maturity assumptions.
- Deeper liability and amortization controls.
- More formal VoiceOver and real-device validation.
- Broader store, persistence, and transaction-balance test coverage.
- Usability testing with people who manage money across multiple places.
- Evaluate a future migration from JSON persistence to SwiftData.
