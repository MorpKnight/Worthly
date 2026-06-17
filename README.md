# Worthly

Worthly is a local-first iOS asset map for people whose money is spread across banks, e-wallets, investments, liabilities, and day-to-day transactions. The current build focuses on a polished SwiftUI interface, guided setup, and a first pass of local financial logic.

## Current Features

- Overview dashboard with net worth, cashflow, planning preview, next actions, and recent transactions.
- Guided setup for building a first money map from an empty install.
- Assets page with liquid accounts, investments, liabilities, and an allocation donut chart.
- Planning page with editable salary, investment, debt, and projection horizon assumptions.
- History page with transaction filters plus add/edit transaction sheets.
- Transfer-aware transaction model with source and destination accounts.
- Local JSON persistence for the demo finance store.
- Settings reset action for starting over with empty local data.

## Project Structure

```text
Worthly/
  Components/     Shared SwiftUI UI components
  Data/           Store, sample data, formatting, and persistence
  Models/         Finance domain models
  *View.swift     Main tab screens
```

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

## Status

This is still a prototype. The UI and local logic are usable for iteration, but not yet production-ready financial software.

Planned next improvements:

- Delete flows for assets, liabilities, and transactions.
- Category management.
- More precise investment return, tax, and maturity assumptions.
- More complete debt amortization behavior.
- Search implementation in History.
- Possible migration from JSON persistence to SwiftData.

## Notes

The app stores edits locally on-device. No backend or cloud sync is implemented.
