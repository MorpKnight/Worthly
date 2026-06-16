# Worthly

Worthly is an iOS personal finance prototype for tracking net worth, liquid assets, SBN investments, liabilities, and day-to-day transaction history. The current build focuses on a polished SwiftUI interface plus a first pass of local financial logic.

## Current Features

- Overview dashboard with net worth, cashflow, planning preview, next actions, and recent transactions.
- Assets page with liquid accounts, SBN investments, liabilities, and an allocation donut chart.
- Planning page with editable salary, investment, debt, and projection horizon assumptions.
- History page with transaction filters plus add/edit transaction sheets.
- Transfer-aware transaction model with source and destination accounts.
- Local JSON persistence for the demo finance store.
- Settings reset action for restoring the sample dataset.

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
- More precise SBN coupon, tax, and maturity assumptions.
- More complete debt amortization behavior.
- Search implementation in History.
- Possible migration from JSON persistence to SwiftData.

## Notes

The app currently ships with sample data and stores edits locally on-device. No backend or cloud sync is implemented.
