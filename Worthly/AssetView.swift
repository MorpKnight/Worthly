//
//  AssetView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct AssetView: View {
    let store: FinanceStore

    @State private var activeEditor: AssetEditor?

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    private var liquidAssets: Decimal {
        store.liquidAssets
    }

    private var investmentPrincipal: Decimal {
        store.investmentPrincipal
    }

    private var totalAssets: Decimal {
        store.totalAssets
    }

    private var totalDebt: Decimal {
        store.totalDebt
    }

    private var hasAssetAllocation: Bool {
        liquidAssets > 0 || investmentPrincipal > 0
    }

    private var allocationSlices: [AssetAllocationSlice] {
        [
            AssetAllocationSlice(
                id: "liquid-account",
                title: "Liquid Account",
                amount: liquidAssets,
                color: AssetChartPalette.liquidAccount
            ),
            AssetAllocationSlice(
                id: "sbn-investment",
                title: "Investments",
                amount: investmentPrincipal,
                color: AssetChartPalette.sbnInvestment
            )
        ]
    }

    private var sortedAccounts: [Account] {
        store.accounts.sorted { $0.balance > $1.balance }
    }

    private var sortedSbnInvestments: [SBNInvestment] {
        store.sbnInvestments.sorted { $0.principal > $1.principal }
    }

    private var sortedDebts: [Debt] {
        store.debts.sorted { $0.remainingAmount > $1.remainingAmount }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                TotalAssetCard(totalAsset: totalAssets)

                if hasAssetAllocation {
                    AssetCompositionChart(slices: allocationSlices)
                        .padding(.top, 2)
                }

                if sortedAccounts.isEmpty {
                    AssetEmptyState {
                        activeEditor = .add(.liquidAccount)
                    }
                } else {
                    AssetSectionHeader(
                        title: "Liquid Account",
                        amount: IDRFormatting.compact(liquidAssets)
                    )

                    VStack(spacing: 0) {
                        ForEach(sortedAccounts) { account in
                            Button {
                                activeEditor = .editAccount(account.id)
                            } label: {
                                WorthlyDisclosureRow(
                                    icon: account.type.systemImage,
                                    title: account.name,
                                    subtitle: account.type.title,
                                    value: IDRFormatting.compact(account.balance),
                                    separatorLeadingInset: 56
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !sortedSbnInvestments.isEmpty {
                    AssetSectionHeader(
                        title: "Investments",
                        amount: IDRFormatting.compact(investmentPrincipal)
                    )

                    VStack(spacing: 0) {
                        ForEach(sortedSbnInvestments) { investment in
                            Button {
                                activeEditor = .editInvestment(investment.id)
                            } label: {
                                WorthlyDisclosureRow(
                                    icon: "percent",
                                    title: investment.name,
                                    subtitle: "\(IDRFormatting.percent(investment.annualInterestRate)) p.a.",
                                    value: IDRFormatting.compact(investment.principal),
                                    separatorLeadingInset: 56
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !sortedDebts.isEmpty {
                    AssetSectionHeader(
                        title: "Liabilities",
                        amount: IDRFormatting.compact(totalDebt)
                    )
                    .padding(.top, 8)

                    VStack(spacing: 0) {
                        ForEach(sortedDebts) { debt in
                            Button {
                                activeEditor = .editDebt(debt.id)
                            } label: {
                                WorthlyDisclosureRow(
                                    icon: debt.name.lowercased().contains("kpr") ? "house" : "creditcard",
                                    title: debt.name,
                                    subtitle: "\(debt.durationMonths) months left",
                                    value: IDRFormatting.compact(debt.remainingAmount),
                                    separatorLeadingInset: 56
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Assets")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorthlyToolbarIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "Add asset"
                ) {
                    activeEditor = .add(.liquidAccount)
                }
            }
        }
        .sheet(item: $activeEditor) { editor in
            switch editor {
            case .add(let initialKind):
                AddAssetEditorSheet(
                    initialKind: initialKind,
                    referenceDate: store.referenceDate,
                    onSaveAccount: { store.addAccount($0) },
                    onSaveInvestment: { store.addInvestment($0) },
                    onSaveDebt: { store.addDebt($0) }
                )
                .presentationDetents([.height(620), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
            case .editAccount(let accountID):
                if let account = store.accounts.first(where: { $0.id == accountID }) {
                    AssetAccountEditorSheet(account: account) { store.updateAccount($0) }
                        .presentationDetents([.height(460), .medium])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                        .presentationBackground(.regularMaterial)
                } else {
                    AssetMissingEditorSheet(title: "Account not found")
                        .presentationDetents([.height(240)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                        .presentationBackground(.regularMaterial)
                }
            case .editInvestment(let investmentID):
                if let investment = store.sbnInvestments.first(where: { $0.id == investmentID }) {
                    AssetInvestmentEditorSheet(investment: investment) { store.updateInvestment($0) }
                        .presentationDetents([.height(540), .medium])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                        .presentationBackground(.regularMaterial)
                } else {
                    AssetMissingEditorSheet(title: "Investment not found")
                        .presentationDetents([.height(240)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                        .presentationBackground(.regularMaterial)
                }
            case .editDebt(let debtID):
                if let debt = store.debts.first(where: { $0.id == debtID }) {
                    AssetDebtEditorSheet(debt: debt) { store.updateDebt($0) }
                        .presentationDetents([.height(580), .medium])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                        .presentationBackground(.regularMaterial)
                } else {
                    AssetMissingEditorSheet(title: "Liability not found")
                        .presentationDetents([.height(240)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                        .presentationBackground(.regularMaterial)
                }
            }
        }
    }
}

private enum AssetEditor: Identifiable {
    case add(AddAssetKind)
    case editAccount(UUID)
    case editInvestment(UUID)
    case editDebt(UUID)

    var id: String {
        switch self {
        case .add(let kind):
            "add-\(kind.rawValue)"
        case .editAccount(let accountID):
            "edit-account-\(accountID.uuidString)"
        case .editInvestment(let investmentID):
            "edit-investment-\(investmentID.uuidString)"
        case .editDebt(let debtID):
            "edit-debt-\(debtID.uuidString)"
        }
    }
}

enum AddAssetKind: String, CaseIterable, Identifiable {
    case liquidAccount
    case sbnInvestment
    case liability

    var id: Self { self }

    var title: String {
        switch self {
        case .liquidAccount:
            "Account"
        case .sbnInvestment:
            "Investment"
        case .liability:
            "Liability"
        }
    }
}

private struct TotalAssetCard: View {
    let totalAsset: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Assets")
                .font(.subheadline)

            WorthlyAmountText(
                text: IDRFormatting.full(totalAsset),
                font: .title2.weight(.bold),
                minimumScaleFactor: 0.78
            )
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

private struct AssetEmptyState: View {
    let onAddAccount: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "wallet.pass")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.blue)

            Text("Add your first account")
                .font(.headline)

            Text("Start with one bank, e-wallet, or cash account.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onAddAccount) {
                Label("Add first account", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

struct AddAssetEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let onSaveAccount: (Account) -> Void
    let onSaveInvestment: (SBNInvestment) -> Void
    let onSaveDebt: (Debt) -> Void

    @State private var selectedKind: AddAssetKind
    @State private var accountDraft: AccountDraft
    @State private var investmentDraft: InvestmentDraft
    @State private var debtDraft: DebtDraft

    init(
        initialKind: AddAssetKind = .liquidAccount,
        referenceDate: Date,
        onSaveAccount: @escaping (Account) -> Void,
        onSaveInvestment: @escaping (SBNInvestment) -> Void,
        onSaveDebt: @escaping (Debt) -> Void
    ) {
        self.onSaveAccount = onSaveAccount
        self.onSaveInvestment = onSaveInvestment
        self.onSaveDebt = onSaveDebt
        _selectedKind = State(initialValue: initialKind)
        _accountDraft = State(initialValue: AccountDraft(referenceDate: referenceDate))
        _investmentDraft = State(initialValue: InvestmentDraft(referenceDate: referenceDate))
        _debtDraft = State(initialValue: DebtDraft(referenceDate: referenceDate))
    }

    private var canSave: Bool {
        switch selectedKind {
        case .liquidAccount:
            accountDraft.isValid
        case .sbnInvestment:
            investmentDraft.isValid
        case .liability:
            debtDraft.isValid
        }
    }

    private var selectedKindBinding: Binding<AddAssetKind> {
        Binding(
            get: { selectedKind },
            set: { newValue in
                guard selectedKind != newValue else {
                    return
                }

                if reduceMotion {
                    selectedKind = newValue
                } else {
                    withAnimation(.snappy(duration: 0.18)) {
                        selectedKind = newValue
                    }
                }
            }
        )
    }

    private var formTransition: AnyTransition {
        reduceMotion ? .identity : .opacity
    }

    var body: some View {
        AssetEditorSheetContainer(
            title: "Add Asset",
            saveIsEnabled: canSave,
            onCancel: { dismiss() },
            onSave: save
        ) {
            VStack(spacing: 12) {
                Picker("Asset type", selection: selectedKindBinding) {
                    ForEach(AddAssetKind.allCases) { kind in
                        Text(kind.title)
                            .tag(kind)
                    }
                }
                .pickerStyle(.segmented)

                AssetEditorFormGroup {
                    Group {
                        switch selectedKind {
                        case .liquidAccount:
                            AssetAccountForm(draft: $accountDraft)
                        case .sbnInvestment:
                            AssetInvestmentForm(draft: $investmentDraft)
                        case .liability:
                            AssetDebtForm(draft: $debtDraft)
                        }
                    }
                    .id(selectedKind)
                    .transition(formTransition)
                }
            }
        }
    }

    private func save() {
        switch selectedKind {
        case .liquidAccount:
            guard let account = accountDraft.account else {
                return
            }

            onSaveAccount(account)
        case .sbnInvestment:
            guard let investment = investmentDraft.investment else {
                return
            }

            onSaveInvestment(investment)
        case .liability:
            guard let debt = debtDraft.debt else {
                return
            }

            onSaveDebt(debt)
        }

        dismiss()
    }
}

private struct AssetAccountEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Account) -> Void

    @State private var draft: AccountDraft

    init(account: Account, onSave: @escaping (Account) -> Void) {
        self.onSave = onSave
        _draft = State(initialValue: AccountDraft(account: account))
    }

    var body: some View {
        AssetEditorSheetContainer(
            title: "Edit Account",
            saveIsEnabled: draft.isValid,
            onCancel: { dismiss() },
            onSave: save
        ) {
            AssetEditorFormGroup {
                AssetAccountForm(draft: $draft)
            }
        }
    }

    private func save() {
        guard let account = draft.account else {
            return
        }

        onSave(account)
        dismiss()
    }
}

private struct AssetInvestmentEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let onSave: (SBNInvestment) -> Void

    @State private var draft: InvestmentDraft

    init(investment: SBNInvestment, onSave: @escaping (SBNInvestment) -> Void) {
        self.title = "Edit \(investment.name)"
        self.onSave = onSave
        _draft = State(initialValue: InvestmentDraft(investment: investment))
    }

    var body: some View {
        AssetEditorSheetContainer(
            title: title,
            saveIsEnabled: draft.isValid,
            onCancel: { dismiss() },
            onSave: save
        ) {
            AssetEditorFormGroup {
                AssetInvestmentForm(draft: $draft)
            }
        }
    }

    private func save() {
        guard let investment = draft.investment else {
            return
        }

        onSave(investment)
        dismiss()
    }
}

private struct AssetDebtEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let onSave: (Debt) -> Void

    @State private var draft: DebtDraft

    init(debt: Debt, onSave: @escaping (Debt) -> Void) {
        self.title = "Edit \(debt.name)"
        self.onSave = onSave
        _draft = State(initialValue: DebtDraft(debt: debt))
    }

    var body: some View {
        AssetEditorSheetContainer(
            title: title,
            saveIsEnabled: draft.isValid,
            onCancel: { dismiss() },
            onSave: save
        ) {
            AssetEditorFormGroup {
                AssetDebtForm(draft: $draft)
            }
        }
    }

    private func save() {
        guard let debt = draft.debt else {
            return
        }

        onSave(debt)
        dismiss()
    }
}

private struct AssetMissingEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String

    var body: some View {
        AssetEditorSheetContainer(
            title: title,
            saveIsEnabled: false,
            onCancel: { dismiss() },
            onSave: {}
        ) {
            Text("Please choose another asset.")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct AssetAccountForm: View {
    @Binding var draft: AccountDraft

    var body: some View {
        AssetEditorTextFieldRow(
            icon: "textformat",
            title: "Name",
            placeholder: "Bank Central Asia",
            text: $draft.name
        )

        AssetEditorMenuRow(
            icon: draft.type.systemImage,
            title: "Type",
            value: draft.type.editorTitle
        ) {
            ForEach(AccountType.allCases) { type in
                Button(type.editorTitle) {
                    draft.type = type
                }
            }
        }

        AssetEditorTextFieldRow(
            icon: "creditcard",
            title: "Balance",
            placeholder: "Rp 0",
            text: $draft.balanceText,
            keyboardType: .decimalPad
        )

        AssetEditorDateRow(
            icon: "calendar",
            title: "Since",
            date: $draft.createdAt
        )
    }
}

private struct AssetInvestmentForm: View {
    @Binding var draft: InvestmentDraft

    var body: some View {
        AssetEditorTextFieldRow(
            icon: "textformat",
            title: "Name",
            placeholder: "Deposit, gold, fund",
            text: $draft.name
        )

        AssetEditorTextFieldRow(
            icon: "banknote",
            title: "Investment Value",
            placeholder: "Rp 0",
            text: $draft.principalText,
            keyboardType: .decimalPad
        )

        AssetEditorTextFieldRow(
            icon: "percent",
            title: "Interest p.a. (%)",
            placeholder: "0",
            text: $draft.annualInterestRateText,
            keyboardType: .decimalPad
        )

        AssetEditorTextFieldRow(
            icon: "calendar.badge.clock",
            title: "Duration (Months)",
            placeholder: "0",
            text: $draft.durationMonthsText,
            keyboardType: .numberPad
        )

        AssetEditorDateRow(
            icon: "calendar",
            title: "Since",
            date: $draft.startDate
        )
    }
}

private struct AssetDebtForm: View {
    @Binding var draft: DebtDraft

    var body: some View {
        AssetEditorTextFieldRow(
            icon: "textformat",
            title: "Name",
            placeholder: "KPR rumah",
            text: $draft.name
        )

        AssetEditorTextFieldRow(
            icon: "banknote",
            title: "Debt Value",
            placeholder: "Rp 0",
            text: $draft.remainingAmountText,
            keyboardType: .decimalPad
        )

        AssetEditorTextFieldRow(
            icon: "percent",
            title: "Interest p.a. (%)",
            placeholder: "0",
            text: $draft.annualInterestRateText,
            keyboardType: .decimalPad
        )

        AssetEditorTextFieldRow(
            icon: "calendar.badge.clock",
            title: "Duration (Months)",
            placeholder: "0",
            text: $draft.durationMonthsText,
            keyboardType: .numberPad
        )

        AssetEditorDateRow(
            icon: "calendar",
            title: "Since",
            date: $draft.startDate
        )
    }
}

private struct AssetEditorSheetContainer<Content: View>: View {
    let title: String
    let saveIsEnabled: Bool
    let onCancel: () -> Void
    let onSave: () -> Void
    let content: Content

    init(
        title: String,
        saveIsEnabled: Bool,
        onCancel: @escaping () -> Void,
        onSave: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.saveIsEnabled = saveIsEnabled
        self.onCancel = onCancel
        self.onSave = onSave
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    AssetSheetCircleButton(
                        systemImage: "xmark",
                        accessibilityLabel: "Cancel",
                        style: .secondary,
                        action: onCancel
                    )

                    Spacer()

                    AssetSheetCircleButton(
                        systemImage: "checkmark",
                        accessibilityLabel: "Save asset",
                        style: saveIsEnabled ? .primary : .disabled,
                        action: onSave
                    )
                    .disabled(!saveIsEnabled)
                }

                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .padding(.horizontal, 62)
            }
            .padding(.top, 14)
            .padding(.horizontal, 8)

            ScrollView {
                content
                    .padding(.top, 18)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 26)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, 14)
    }
}

private struct AssetSheetCircleButton: View {
    enum Style {
        case primary
        case secondary
        case disabled
    }

    let systemImage: String
    let accessibilityLabel: String
    let style: Style
    let action: () -> Void

    private var background: Color {
        switch style {
        case .primary:
            .blue
        case .secondary, .disabled:
            Color(.systemGray5)
        }
    }

    private var foreground: Color {
        switch style {
        case .primary:
            .white
        case .secondary:
            .primary
        case .disabled:
            .secondary.opacity(0.45)
        }
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(foreground)
                .frame(width: 44, height: 44)
                .background(background, in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct AssetEditorFormGroup<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 22, style: .continuous)
        )
    }
}

private struct AssetEditorTextFieldRow: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(.primary)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: $text)
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
        }
        .frame(minHeight: 58)
        .overlay(alignment: .bottom) {
            AssetEditorSeparator()
                .padding(.leading, 44)
        }
    }
}

private struct AssetEditorMenuRow<MenuContent: View>: View {
    let icon: String
    let title: String
    let value: String
    let menuContent: MenuContent

    init(
        icon: String,
        title: String,
        value: String,
        @ViewBuilder menuContent: () -> MenuContent
    ) {
        self.icon = icon
        self.title = title
        self.value = value
        self.menuContent = menuContent()
    }

    var body: some View {
        Menu {
            menuContent
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer(minLength: 12)

                Text(value)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .frame(minHeight: 52)
            .overlay(alignment: .bottom) {
                AssetEditorSeparator()
                    .padding(.leading, 44)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct AssetEditorDateRow: View {
    let icon: String
    let title: String
    @Binding var date: Date

    var body: some View {
        DatePicker(
            selection: $date,
            displayedComponents: .date
        ) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            AssetEditorSeparator()
                .padding(.leading, 44)
        }
    }
}

private struct AssetEditorSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
    }
}

private struct AssetCompositionChart: View {
    let slices: [AssetAllocationSlice]

    private var positiveSlices: [AssetAllocationSlice] {
        slices.filter { $0.amount > 0 }
    }

    private var totalAmount: Decimal {
        positiveSlices.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Asset Allocation")
                    .font(.headline)

                Text("Liquid accounts + investments")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: 18) {
                    AssetDonutChart(slices: positiveSlices)
                        .frame(width: 164, height: 164)

                    allocationLegend
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: 12) {
                    AssetDonutChart(slices: positiveSlices)
                        .frame(width: 216, height: 216)
                        .frame(maxWidth: .infinity)

                    allocationLegend
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var allocationLegend: some View {
        VStack(spacing: 8) {
            ForEach(positiveSlices) { slice in
                AllocationLegendRow(
                    slice: slice,
                    percentage: percentageText(for: slice)
                )
            }
        }
    }

    private var accessibilitySummary: String {
        guard totalAmount > 0 else {
            return "Asset allocation chart, no assets"
        }

        let summary = positiveSlices
            .map { "\($0.title) \(percentageText(for: $0))" }
            .joined(separator: ", ")

        return "Asset allocation chart, \(summary)"
    }

    private func percentageText(for slice: AssetAllocationSlice) -> String {
        guard totalAmount > 0 else {
            return "0%"
        }

        let sliceValue = NSDecimalNumber(decimal: slice.amount).doubleValue
        let totalValue = NSDecimalNumber(decimal: totalAmount).doubleValue
        let percentage = sliceValue / totalValue * 100

        if percentage > 0 && percentage < 1 {
            return "<1%"
        }

        if abs(percentage.rounded() - percentage) < 0.05 {
            return "\(Int(percentage.rounded()))%"
        }

        return String(format: "%.1f%%", percentage)
    }
}

private struct AssetDonutChart: View {
    let slices: [AssetAllocationSlice]

    private var totalValue: Double {
        slices.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        ZStack {
            Canvas { context, size in
                let lineWidth = min(size.width, size.height) * 0.22
                let radius = min(size.width, size.height) / 2 - lineWidth / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                var startAngle = -90.0

                var basePath = Path()
                basePath.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    clockwise: false
                )

                context.stroke(
                    basePath,
                    with: .color(Color(.quaternarySystemFill)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )

                guard totalValue > 0 else {
                    return
                }

                for slice in slices {
                    let endAngle = startAngle + 360 * (slice.value / totalValue)
                    var path = Path()

                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle),
                        clockwise: false
                    )

                    context.stroke(
                        path,
                        with: .color(slice.color),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )

                    startAngle = endAngle
                }
            }

            VStack(spacing: 2) {
                Text("Assets")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(totalValue > 0 ? "100%" : "0%")
                    .font(.title3.weight(.bold))
                    .monospacedDigit()
            }
        }
        .accessibilityLabel("Asset allocation donut chart")
    }
}

private struct AllocationLegendRow: View {
    let slice: AssetAllocationSlice
    let percentage: String

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(slice.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(slice.title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Text(percentage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            WorthlyAmountText(
                text: IDRFormatting.compact(slice.amount),
                font: .subheadline,
                color: .secondary
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

private struct AssetAllocationSlice: Identifiable {
    let id: String
    let title: String
    let amount: Decimal
    let color: Color

    var value: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

private enum AssetChartPalette {
    // These pairs clear the HIG/WCAG contrast equation target of 3:1
    // against system white in light mode and system black in dark mode.
    static let liquidAccount = adaptiveColor(
        light: ChartRGB(red: 0, green: 87, blue: 217),
        dark: ChartRGB(red: 121, green: 167, blue: 255)
    )

    static let sbnInvestment = adaptiveColor(
        light: ChartRGB(red: 0, green: 122, blue: 120),
        dark: ChartRGB(red: 72, green: 214, blue: 210)
    )

    private static func adaptiveColor(light: ChartRGB, dark: ChartRGB) -> Color {
        Color(
            uiColor: UIColor { traitCollection in
                let rgb = traitCollection.userInterfaceStyle == .dark ? dark : light

                return UIColor(
                    red: rgb.red,
                    green: rgb.green,
                    blue: rgb.blue,
                    alpha: 1
                )
            }
        )
    }
}

private struct ChartRGB {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat

    init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.red = red / 255
        self.green = green / 255
        self.blue = blue / 255
    }
}

private struct AssetSectionHeader: View {
    let title: String
    let amount: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)

            Spacer()

            WorthlyAmountText(text: amount, font: .body, color: .secondary)
        }
    }
}

private struct AccountDraft {
    let id: UUID
    var name: String
    var type: AccountType
    var balanceText: String
    var createdAt: Date

    init(referenceDate: Date) {
        id = UUID()
        name = ""
        type = .bank
        balanceText = ""
        createdAt = referenceDate
    }

    init(account: Account) {
        id = account.id
        name = account.name
        type = account.type
        balanceText = IDRFormatting.full(account.balance)
        createdAt = account.createdAt
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var balance: Decimal? {
        AssetInputFormatting.decimal(from: balanceText)
    }

    var isValid: Bool {
        guard let balance else {
            return false
        }

        return !trimmedName.isEmpty && balance > 0
    }

    var account: Account? {
        guard let balance, isValid else {
            return nil
        }

        return Account(
            id: id,
            name: trimmedName,
            type: type,
            balance: balance,
            createdAt: createdAt
        )
    }
}

private struct InvestmentDraft {
    let id: UUID
    var name: String
    var principalText: String
    var annualInterestRateText: String
    var durationMonthsText: String
    var startDate: Date

    init(referenceDate: Date) {
        id = UUID()
        name = ""
        principalText = ""
        annualInterestRateText = ""
        durationMonthsText = "24"
        startDate = referenceDate
    }

    init(investment: SBNInvestment) {
        id = investment.id
        name = investment.name
        principalText = IDRFormatting.full(investment.principal)
        annualInterestRateText = AssetInputFormatting.decimalText(investment.annualInterestRate)
        durationMonthsText = "\(investment.durationMonths)"
        startDate = investment.startDate
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var principal: Decimal? {
        AssetInputFormatting.decimal(from: principalText)
    }

    private var annualInterestRate: Decimal? {
        AssetInputFormatting.decimal(from: annualInterestRateText)
    }

    private var durationMonths: Int? {
        AssetInputFormatting.integer(from: durationMonthsText)
    }

    var isValid: Bool {
        guard let principal, let annualInterestRate, let durationMonths else {
            return false
        }

        return !trimmedName.isEmpty
            && principal > 0
            && annualInterestRate >= 0
            && durationMonths > 0
    }

    var investment: SBNInvestment? {
        guard let principal, let annualInterestRate, let durationMonths, isValid else {
            return nil
        }

        return SBNInvestment(
            id: id,
            name: trimmedName,
            principal: principal,
            annualInterestRate: annualInterestRate,
            durationMonths: durationMonths,
            startDate: startDate
        )
    }
}

private struct DebtDraft {
    let id: UUID
    var name: String
    var remainingAmountText: String
    var annualInterestRateText: String
    var durationMonthsText: String
    var startDate: Date

    init(referenceDate: Date) {
        id = UUID()
        name = ""
        remainingAmountText = ""
        annualInterestRateText = ""
        durationMonthsText = "12"
        startDate = referenceDate
    }

    init(debt: Debt) {
        id = debt.id
        name = debt.name
        remainingAmountText = IDRFormatting.full(debt.remainingAmount)
        annualInterestRateText = AssetInputFormatting.decimalText(debt.annualInterestRate)
        durationMonthsText = "\(debt.durationMonths)"
        startDate = debt.startDate
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var remainingAmount: Decimal? {
        AssetInputFormatting.decimal(from: remainingAmountText)
    }

    private var annualInterestRate: Decimal? {
        AssetInputFormatting.decimal(from: annualInterestRateText)
    }

    private var durationMonths: Int? {
        AssetInputFormatting.integer(from: durationMonthsText)
    }

    var isValid: Bool {
        guard let remainingAmount, let annualInterestRate, let durationMonths else {
            return false
        }

        return !trimmedName.isEmpty
            && remainingAmount > 0
            && annualInterestRate >= 0
            && durationMonths > 0
    }

    var debt: Debt? {
        guard let remainingAmount, let annualInterestRate, let durationMonths, isValid else {
            return nil
        }

        return Debt(
            id: id,
            name: trimmedName,
            remainingAmount: remainingAmount,
            annualInterestRate: annualInterestRate,
            durationMonths: durationMonths,
            startDate: startDate
        )
    }
}

private enum AssetInputFormatting {
    static func decimalText(_ amount: Decimal) -> String {
        NSDecimalNumber(decimal: amount).stringValue
    }

    static func decimal(from text: String) -> Decimal? {
        let allowedCharacters = CharacterSet(charactersIn: "0123456789.,")
        let filteredScalars = text.unicodeScalars.filter { allowedCharacters.contains($0) }
        var normalized = String(String.UnicodeScalarView(filteredScalars))

        guard !normalized.isEmpty else {
            return nil
        }

        if normalized.contains(",") {
            normalized = normalized
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: ".")
        } else if normalized.filter({ $0 == "." }).count > 1 {
            normalized = normalized.replacingOccurrences(of: ".", with: "")
        }

        return Decimal(
            string: normalized,
            locale: Locale(identifier: "en_US_POSIX")
        )
    }

    static func integer(from text: String) -> Int? {
        let digits = text.filter { $0.isNumber }

        guard !digits.isEmpty else {
            return nil
        }

        return Int(digits)
    }
}

private extension AccountType {
    var editorTitle: String {
        switch self {
        case .bank:
            "Bank"
        case .eWallet:
            "e-wallet"
        case .cash:
            "Cash"
        }
    }
}

#Preview {
    NavigationStack {
        AssetView()
    }
}
