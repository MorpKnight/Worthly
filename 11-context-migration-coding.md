# Context Migration: AssetFlow / Personal Finance Tracker Coding Handoff

Gunakan dokumen ini untuk memulai chat coding baru. Bagian `Prompt to paste` bisa langsung ditempel ke agent/coding chat lain.

## Prompt to paste

Saya sedang membangun iOS app untuk Apple Developer Academy challenge. Tolong lanjutkan dari konteks berikut dan bantu saya coding MVP-nya.

### Project Context

- Workspace root: `/Users/giovan/Programming/ios/challenge-3`
- Current CBL phase: Act, masuk ke Coding setelah design exploration.
- App concept: local-first personal finance / asset tracker untuk mencatat aset, transaksi income/outcome, investasi surat negara, cicilan/utang, dan estimasi net worth akhir tahun.
- Working app name: `AssetFlow` untuk coding. Nama final masih bisa berubah; kandidat nama yang disukai: `Artha`, `Worthly`, atau `AssetFlow`.
- Target platform: iOS 26.
- Primary test device: iPhone 17 portrait.
- Framework preference: SwiftUI.
- Data storage preference: local-first. Gunakan SwiftData jika project target sudah memungkinkan; fallback ke in-memory sample model untuk prototype bila perlu.
- Currency: IDR only.
- No authentication, no backend, no cloud sync, no bank integration, no stock/crypto, no financial advice.

### Challenge / Learning Goal

Refined Challenge Statement:

`Fill my knowledge/skill gap in designing clear layout, navigation, color communication, and typography by creating a personal finance tracker for income, expenses, assets, and cash flow.`

Challenge Response:

`An iOS app to fill my knowledge/skill gap in information design by helping me track income, expenses, assets, and cash flow through clear layout, navigation, color, and typography.`

### Important Source Artifacts

Read these files first:

- `/Users/giovan/Programming/ios/challenge-3/cbl-artifacts/06-act-user-flow-ia-screen-breakdown.md`
- `/Users/giovan/Programming/ios/challenge-3/cbl-artifacts/07-design-guidelines-ios26.md`
- `/Users/giovan/Programming/ios/challenge-3/cbl-artifacts/09-hig-refresh-screen-design.md`
- `/Users/giovan/Programming/ios/challenge-3/cbl-artifacts/10-apple-hig-audit-current-design.md`

Note: Some older artifacts mention 4 tabs (`Overview`, `Transactions`, `Assets`, `Projection`). The final design direction changed this to 5 tabs:

1. `Overview`
2. `Planning`
3. `Assets`
4. `History`
5. `Settings`

Use the 5-tab design as the coding source of truth.

Relevant wireframe images:

- `/Users/giovan/Programming/ios/challenge-3/cbl-artifacts/diagrams/assetflow-hig-parent-tabs-wireframe.png`
- `/Users/giovan/Programming/ios/challenge-3/cbl-artifacts/diagrams/assetflow-hig-transactions-settings-wireframe.png`
- `/Users/giovan/Programming/ios/challenge-3/cbl-artifacts/diagrams/assetflow-hig-assets-profile-wireframe.png`
- `/Users/giovan/Programming/ios/challenge-3/cbl-artifacts/diagrams/assetflow-hig-onboarding-wireframe.png`

### Final Design Direction

The latest final design uses these screens and flows:

#### Tab 1: Overview

Purpose: answer “How is my money doing right now?”

Main content:

- Current Net Worth card.
- Supporting explanation: `Liquid Asset + SBN - Debt`.
- Compact metrics:
  - Cashflow.
  - View Planning / year-end estimate.
- Next action checklist:
  - Add salary.
  - Add investment.
  - Add debt.
- Recent Transactions list with only a few recent items.
- Toolbar `+` action for global creation.

Implementation notes:

- Overview should not duplicate all information from every tab.
- It is a summary dashboard.
- Recent transactions should be limited to 3-5 rows.

#### Tab 2: Planning

Purpose: estimate future net worth and expose projection assumptions.

Main content:

- Projected Dec 31 value.
- Gap value, currently shown as negative red amount.
- Assumptions:
  - Monthly salary.
  - SBN coupons monthly.
  - Debt installments monthly.
  - Projection horizon.
- Tapping assumptions opens edit flows:
  - Edit Monthly Salary sheet.
  - Choose/Edit Investment sheet.
  - Choose/Edit Debt sheet.
  - Projection horizon calendar/date picker.

Implementation notes:

- `Gap` needs a clear label. Prefer `Gap to target` or `Remaining to goal` if a target exists.
- Projection must clearly say it is an estimate, not financial advice.
- Projection formula can stay simple for MVP.

#### Tab 3: Assets

Purpose: answer “Where is my money stored and what obligations exist?”

Main content:

- Total Asset card.
- Pie chart / asset composition visual.
- Sections:
  - Liquid Account.
  - SBN Investment.
  - Debt / Cicilan.
- Rows show name, subtitle, amount, chevron.
- Toolbar `+` opens Add Asset sheet.

Add Asset sheet:

- Choices:
  - Bank & e-Wallet.
  - Investment.
  - Debt / Cicilan.

Asset forms:

- Add Bank & e-Wallet:
  - Name.
  - Asset amount.
- Add Investment:
  - Name.
  - Asset / principal.
  - Interest p.a. (%).
  - Duration.
  - Starting date.
- Add Debt / Cicilan:
  - Name.
  - Debt value.
  - Interest p.a. (%).
  - Duration.
  - Starting date.
- Some detail/edit variants show result summaries:
  - Debt billing per month.
  - Investment coupons per month.

Implementation notes:

- Pie chart needs labels/legend or at least textual equivalent through list rows.
- Add bottom padding so last list rows are not hidden by tab bar.

#### Tab 4: History

Purpose: review, search, and edit transaction logs.

Main content:

- Filter control:
  - All.
  - Income.
  - Expense.
  - Account.
- Search field.
- June summary card:
  - Total monthly amount.
  - Number of transactions.
- Transaction list grouped by:
  - Today.
  - Yesterday.
  - Older groups if needed.
- Toolbar `+` opens Add Transaction sheet.

Add/Edit Transaction sheet:

- Amount first.
- Segmented control:
  - Income.
  - Outcome.
- Rows:
  - Category.
  - Account.
  - Date.
  - Notes.
- Save action currently represented as blue circular check.

Implementation notes:

- When saving income transaction, selected account balance increases.
- When saving outcome transaction, selected account balance decreases.
- Editing/deleting a transaction must reverse old balance impact, then apply the new impact.
- For accessibility, check button should have clear label such as `Save transaction`.

#### Tab 5: Settings

Purpose: app preferences and local data controls.

Main content:

- Preferences:
  - Currency: IDR.
  - Categories: Default.
- Data and app:
  - Local data only.
  - Reset demo data.

Implementation notes:

- Settings should not show a global `+`.
- Use grouped list style.
- Reset demo data should be visually destructive and preferably confirmed.

### Data Model

Use simple local models:

```swift
enum AccountType {
    case bank
    case eWallet
    case cash
}

enum TransactionType {
    case income
    case outcome
}

struct Account {
    var id: UUID
    var name: String
    var type: AccountType
    var balance: Decimal
    var createdAt: Date
}

struct Transaction {
    var id: UUID
    var type: TransactionType
    var amount: Decimal
    var category: String
    var accountID: UUID
    var date: Date
    var note: String
}

struct SBNInvestment {
    var id: UUID
    var name: String
    var principal: Decimal
    var annualInterestRate: Decimal
    var durationMonths: Int
    var startDate: Date
}

struct Debt {
    var id: UUID
    var name: String
    var remainingAmount: Decimal
    var annualInterestRate: Decimal
    var durationMonths: Int
    var startDate: Date
}

struct RecurringIncome {
    var id: UUID
    var name: String
    var amount: Decimal
    var payday: Int
}
```

Older docs used `monthlyCoupon`, `maturityDate`, `monthlyInstallment`, and `endDate`. Final design uses interest rate and duration in the forms. For MVP, choose one consistent implementation:

- Preferred for coding simplicity: store both calculated and raw fields if useful, but keep the UI as final design:
  - User inputs `principal`, `annualInterestRate`, `durationMonths`, `startDate`.
  - App calculates estimated monthly coupon/payment for display.

### Projection Rule

Default horizon: December 31 of the current year, or selected horizon from Planning calendar.

Simple MVP formula:

```text
current liquid assets
+ active investment principal
- active debt remaining amount
= current net worth

current net worth
+ future salary payments until horizon
+ estimated future investment coupon payments until horizon
- estimated future debt installment payments until horizon
= projected net worth
```

Keep projection labelled as an estimate. Exclude:

- unplanned spending,
- market changes,
- tax,
- financial advice.

### Currency Formatting

- Display IDR.
- Use monospaced digits for money values.
- For large values in compact cards/rows, use compact format:
  - `Rp 9M`
  - `Rp 150.4M`
  - `Rp 1.2B`
- Use full amount in detail/edit screens if space allows.
- For IDR, decimal fractions are usually unnecessary; avoid `,99` unless intentionally tracking cents.

### Design Guidelines

Follow existing design decisions:

- Calm, precise, financially clear.
- HIG as baseline.
- Use SwiftUI native `TabView`, `NavigationStack`, `.sheet`, `Form`/grouped list patterns where appropriate.
- Main screen horizontal padding around 20 pt.
- Use Dynamic Type-friendly system text styles.
- Keep touch targets at least 44 x 44 pt.
- Do not rely on color alone:
  - Income should show `+`.
  - Expense/debt should show `-` or text label.
- Semantic color roles:
  - Accent/action: blue.
  - Income: green.
  - Expense: red/coral.
  - Investment/SBN: teal or blue-green.
  - Debt/cicilan: amber/red depending state.
  - Planning/projection: blue/violet accent.

### Current Design Feedback to Preserve

The design was reviewed and judged around 8/10. It is good enough to build. Do not redesign from scratch.

Things to preserve:

- 5-tab structure.
- Amount-first transaction sheet.
- Bottom sheet add/edit patterns.
- Assets pie chart + grouped asset sections.
- Planning assumptions list.
- Settings as simple grouped list.

Small polish items to consider while coding:

- Add chart legend / textual equivalent.
- Make `Gap` label clearer.
- Use compact currency for cards/rows.
- Make checklist look like checklist, not radio buttons.
- Avoid `+` in Settings.
- Give save/check buttons accessibility labels.
- Ensure bottom safe area padding above tab bar.

### Recommended Coding Plan

1. Inspect whether an Xcode/SwiftUI project already exists in `/Users/giovan/Programming/ios/challenge-3`.
2. If no project exists, ask before scaffolding or create a SwiftUI iOS app project if instructed.
3. Implement app shell:
   - `TabView`
   - 5 tabs: Overview, Planning, Assets, History, Settings.
   - Per-tab `NavigationStack`.
4. Implement sample local data store first.
5. Implement shared components:
   - Money formatter.
   - Metric card.
   - Transaction row.
   - Asset row.
   - Section header with trailing total.
   - Bottom sheet editor shell.
6. Build parent tabs using sample data.
7. Add sheets:
   - Add Transaction.
   - Edit Transaction.
   - Add Asset choice sheet.
   - Add Bank & e-Wallet.
   - Add Investment.
   - Add Debt / Cicilan.
   - Edit Monthly Salary.
8. Wire data mutations:
   - Add/edit transaction updates account balance.
   - Assets affect total asset and net worth.
   - Salary/investment/debt affect Planning projection.
9. Run the app on iPhone simulator.
10. Verify UI:
   - no text overlap,
   - tab bar not hiding content,
   - Dynamic Type basic resilience,
   - add/edit flows work,
   - projection updates.

### Important Behavior Tests

- New transaction income increases account balance.
- New transaction expense decreases account balance.
- Editing transaction reverses old balance impact and applies new impact.
- Deleting transaction reverses balance impact.
- Adding asset updates Assets and Overview.
- Adding debt reduces net worth.
- Adding salary changes Planning projection.
- Projection horizon changes projection result.
- Settings reset demo data asks confirmation.

### Tone / Collaboration Preference

The user wants help building the working iOS app, not more broad ideation. Be proactive: inspect the codebase, implement, run/build/test when possible, and keep changes scoped to MVP.

Do not over-refactor. Do not introduce backend/auth/cloud sync. Do not redesign the final screens unless something is impossible to implement.

## Extra notes for current thread

Final visual design was provided as a screenshot in the previous chat, showing:

- top row: Overview, Assets, History, Planning, Settings,
- bottom sheets for Add Asset, Add Transaction, Edit Monthly Salary,
- add/edit flows for Debt, Investment, Bank & E-Wallet, Transaction,
- Planning horizon calendar.

The screenshot itself may have been temporary. If the next chat cannot access it, rely on this context migration plus the artifact files listed above.
