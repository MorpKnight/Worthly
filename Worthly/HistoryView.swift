//
//  HistoryView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct HistoryView: View {
    let store: FinanceStore

    @State private var selectedFilter = HistoryFilter.all
    @State private var activeEditor: HistoryTransactionEditor?

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    private var filteredTransactions: [FinanceTransaction] {
        store.transactions(for: selectedFilter.transactionType)
    }

    private var transactionGroups: [FinanceTransactionGroup] {
        store.groupedTransactions(for: filteredTransactions)
    }

    private var referenceMonthSummary: (total: Decimal, count: Int) {
        store.referenceMonthSummary
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                Picker("Transaction filter", selection: $selectedFilter) {
                    ForEach(HistoryFilter.allCases) { filter in
                        Text(filter.title)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                SearchField()

                if store.transactions.isEmpty {
                    HistoryEmptyState()
                } else {
                    JuneSummaryCard(
                        total: referenceMonthSummary.total,
                        count: referenceMonthSummary.count
                    )

                    if transactionGroups.isEmpty {
                        HistoryFilterEmptyState()
                    } else {
                        ForEach(transactionGroups) { group in
                            HistorySection(title: group.title) {
                                ForEach(group.transactions) { transaction in
                                    Button {
                                        activeEditor = .edit(transaction.id)
                                    } label: {
                                        WorthlyTransactionRow(
                                            icon: transaction.displayIcon,
                                            title: transaction.category,
                                            subtitle: transaction.subtitle(
                                                accountName: store.accountName(for: transaction.accountID),
                                                destinationAccountName: store.destinationAccountName(for: transaction)
                                            ),
                                            amount: transaction.displayAmount,
                                            iconTint: transaction.displayTint
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, WorthlySpacing.screenHorizontal)
            .padding(.top, WorthlySpacing.xs)
            .padding(.bottom, WorthlySpacing.pageBottom)
        }
        .background(Color(.systemBackground))
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorthlyToolbarIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "Add transaction"
                ) {
                    activeEditor = .add
                }
            }
        }
        .sheet(item: $activeEditor) { editor in
            switch editor {
            case .add:
                HistoryTransactionEditorSheet(
                    mode: .add,
                    transaction: nil,
                    accounts: store.accounts,
                    referenceDate: store.referenceDate,
                    onSave: { store.addTransaction($0) }
                )
                .presentationDetents([.height(520), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
            case .edit(let transactionID):
                if let transaction = store.transactions.first(where: { $0.id == transactionID }) {
                    HistoryTransactionEditorSheet(
                        mode: .edit,
                        transaction: transaction,
                        accounts: store.accounts,
                        referenceDate: store.referenceDate,
                        onSave: { store.updateTransaction($0) }
                    )
                    .presentationDetents([.height(520), .medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
                    .presentationBackground(.regularMaterial)
                } else {
                    HistoryMissingTransactionSheet()
                        .presentationDetents([.height(240)])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                        .presentationBackground(.regularMaterial)
                }
            }
        }
    }
}

private struct HistoryEmptyState: View {
    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
            Image(systemName: "list.bullet.rectangle")
                .font(.title2.weight(.semibold))
                .foregroundStyle(WorthlyAccessibleColor.accent)

            Text("No transactions yet")
                .font(.headline)

            Text("Income, expenses, and account transfers will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthlySpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

private struct HistoryFilterEmptyState: View {
    var body: some View {
        Text("No transactions match this filter.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
    }
}

private enum HistoryTransactionEditor: Identifiable {
    case add
    case edit(UUID)

    var id: String {
        switch self {
        case .add:
            "add"
        case .edit(let transactionID):
            "edit-\(transactionID.uuidString)"
        }
    }
}

private enum HistoryFilter: String, CaseIterable, Identifiable {
    case all
    case income
    case expense
    case account

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            "All"
        case .income:
            "Income"
        case .expense:
            "Expense"
        case .account:
            "Account"
        }
    }

    var transactionType: FinanceTransactionType? {
        switch self {
        case .all:
            nil
        case .income:
            .income
        case .expense:
            .outcome
        case .account:
            .account
        }
    }
}

private struct SearchField: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: dynamicTypeSize.isWorthlyAccessibilitySize ? .top : .center, spacing: WorthlySpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)

            Text("Search")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 1)

            Spacer(minLength: WorthlySpacing.xs)

            Image(systemName: "mic")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, WorthlySpacing.sm)
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.sm : 0)
        .frame(minHeight: 48)
        .background(Color(.secondarySystemGroupedBackground), in: Capsule())
        .accessibilityLabel("Search transactions")
    }
}

private struct JuneSummaryCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let total: Decimal
    let count: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .bottom) {
                amountBlock

                Spacer()

                countBlock
            }

            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                amountBlock
                countBlock
            }
        }
        .padding(WorthlySpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
        .background(WorthlyCardBackground())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("June summary, \(IDRFormatting.signedCompact(total)), \(count) transactions")
    }

    private var amountColor: Color {
        total < 0 ? WorthlyAccessibleColor.negative : WorthlyAccessibleColor.positive
    }

    private var amountBlock: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.md) {
            Text("June summary")
                .font(.caption)

            WorthlyAmountText(
                text: IDRFormatting.signedCompact(total),
                font: .title3.weight(.bold),
                color: amountColor
            )
        }
    }

    private var countBlock: some View {
        VStack(alignment: dynamicTypeSize.isWorthlyAccessibilitySize ? .leading : .trailing, spacing: WorthlySpacing.xxs) {
            WorthlyAmountText(text: "\(count)x", font: .caption)

            Text("Transactions")
                .font(.caption)
        }
    }
}

private struct HistorySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            Text(title)
                .font(.headline)

            VStack(spacing: 0) {
                content
            }
        }
    }
}

private enum HistoryEditorMode {
    case add
    case edit

    var title: String {
        switch self {
        case .add:
            "Add Transaction"
        case .edit:
            "Edit Transaction"
        }
    }
}

private enum HistoryEditorTransactionType: String, CaseIterable, Identifiable {
    case income
    case outcome
    case account

    var id: Self { self }

    var title: String {
        switch self {
        case .income:
            "Income"
        case .outcome:
            "Outcome"
        case .account:
            "Account"
        }
    }

    var transactionType: FinanceTransactionType {
        switch self {
        case .income:
            .income
        case .outcome:
            .outcome
        case .account:
            .account
        }
    }

    var categories: [String] {
        switch self {
        case .income:
            ["Salary", "Investment return", "Freelance", "Cashback", "Gift", "Side project"]
        case .outcome:
            ["Food", "Groceries", "Debt installment", "Restaurant", "Transport", "Travel", "Phone", "Shopping", "Rent", "Health", "Education", "Coffee"]
        case .account:
            ["Transfer", "Top up", "Savings sweep"]
        }
    }

    var defaultCategory: String {
        categories[0]
    }

    init(transactionType: FinanceTransactionType) {
        switch transactionType {
        case .income:
            self = .income
        case .outcome:
            self = .outcome
        case .account:
            self = .account
        }
    }
}

private struct HistoryTransactionEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let mode: HistoryEditorMode
    let transaction: FinanceTransaction?
    let accounts: [Account]
    let referenceDate: Date
    let onSave: (FinanceTransaction) -> Void

    @State private var amountText: String
    @State private var editorType: HistoryEditorTransactionType
    @State private var category: String
    @State private var accountID: UUID?
    @State private var destinationAccountID: UUID?
    @State private var date: Date
    @State private var note: String

    init(
        mode: HistoryEditorMode,
        transaction: FinanceTransaction?,
        accounts: [Account],
        referenceDate: Date,
        onSave: @escaping (FinanceTransaction) -> Void
    ) {
        let initialType = HistoryEditorTransactionType(transactionType: transaction?.type ?? .income)
        let initialAccountID = transaction?.accountID ?? accounts.first?.id
        let initialDestinationAccountID = transaction?.destinationAccountID
            ?? accounts.first { account in
                guard let initialAccountID else {
                    return true
                }

                return account.id != initialAccountID
            }?.id

        self.mode = mode
        self.transaction = transaction
        self.accounts = accounts
        self.referenceDate = referenceDate
        self.onSave = onSave
        _amountText = State(initialValue: HistoryInputFormatting.currency(transaction?.amount ?? 0))
        _editorType = State(initialValue: initialType)
        _category = State(initialValue: transaction?.category ?? initialType.defaultCategory)
        _accountID = State(initialValue: initialAccountID)
        _destinationAccountID = State(initialValue: initialDestinationAccountID)
        _date = State(initialValue: transaction?.date ?? referenceDate)
        _note = State(initialValue: transaction?.note ?? "")
    }

    private var amount: Decimal? {
        HistoryInputFormatting.decimal(from: amountText)
    }

    private var selectedAccount: Account? {
        guard let accountID else {
            return nil
        }

        return accounts.first { $0.id == accountID }
    }

    private var selectedDestinationAccount: Account? {
        guard let destinationAccountID else {
            return nil
        }

        return accounts.first { $0.id == destinationAccountID }
    }

    private var canSave: Bool {
        guard let amount, amount > 0, selectedAccount != nil else {
            return false
        }

        if editorType == .account {
            guard let destinationAccountID else {
                return false
            }

            return !category.isEmpty && destinationAccountID != accountID
        }

        return !category.isEmpty
    }

    private var amountHelperText: String {
        guard let amount, amount > 0 else {
            return "Enter the transaction amount first"
        }

        if editorType == .account {
            let source = selectedAccount?.shortDisplayName ?? "account"
            let destination = selectedDestinationAccount?.shortDisplayName ?? "destination"

            return "Transfer from \(source) to \(destination)"
        }

        return "\(editorType.title) through \(selectedAccount?.shortDisplayName ?? "account")"
    }

    var body: some View {
        HistorySheetContainer(
            title: mode.title,
            saveIsEnabled: canSave,
            onCancel: { dismiss() },
            onSave: save
        ) {
            VStack(spacing: WorthlySpacing.sm) {
                VStack(spacing: WorthlySpacing.xs) {
                    Text("Amount")
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Rp 0", text: $amountText, axis: .vertical)
                        .font(.largeTitle.weight(.bold))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? 1...2 : 1...1)
                        .minimumScaleFactor(dynamicTypeSize.isWorthlyAccessibilitySize ? 1 : 0.65)

                    Text(amountHelperText)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }

                Picker("Transaction type", selection: $editorType) {
                    ForEach(HistoryEditorTransactionType.allCases) { type in
                        Text(type.title)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: editorType) { _, newType in
                    if !newType.categories.contains(category) {
                        category = newType.defaultCategory
                    }

                    if newType == .account {
                        repairDestinationAccount()
                    }
                }

                VStack(spacing: 0) {
                    HistoryEditorMenuRow(
                        icon: "tag",
                        title: "Category",
                        value: category
                    ) {
                        ForEach(editorType.categories, id: \.self) { category in
                            Button(category) {
                                self.category = category
                            }
                        }
                    }

                    HistoryEditorMenuRow(
                        icon: "wallet.pass",
                        title: editorType == .account ? "From" : "Account",
                        value: selectedAccount?.shortDisplayName ?? "Account"
                    ) {
                        ForEach(accounts) { account in
                            Button(account.shortDisplayName) {
                                accountID = account.id
                                repairDestinationAccount()
                            }
                        }
                    }

                    if editorType == .account {
                        HistoryEditorMenuRow(
                            icon: "arrow.right",
                            title: "To",
                            value: selectedDestinationAccount?.shortDisplayName ?? "Account"
                        ) {
                            ForEach(accounts.filter { account in
                                guard let accountID else {
                                    return true
                                }

                                return account.id != accountID
                            }) { account in
                                Button(account.shortDisplayName) {
                                    destinationAccountID = account.id
                                }
                            }
                        }
                    }

                    HistoryEditorDateRow(date: $date)

                    HistoryEditorNotesRow(note: $note)
                }
                .padding(.horizontal, WorthlySpacing.md)
                .padding(.vertical, WorthlySpacing.xs)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: WorthlySpacing.xl, style: .continuous)
                )
            }
        }
    }

    private func save() {
        guard let amount, let accountID, canSave else {
            return
        }

        let transaction = FinanceTransaction(
            id: transaction?.id ?? UUID(),
            type: editorType.transactionType,
            amount: amount,
            category: category,
            accountID: accountID,
            destinationAccountID: editorType == .account ? destinationAccountID : nil,
            date: date,
            note: note
        )

        onSave(transaction)
        dismiss()
    }

    private func repairDestinationAccount() {
        guard editorType == .account else {
            destinationAccountID = nil
            return
        }

        if destinationAccountID == nil || destinationAccountID == accountID {
            destinationAccountID = accounts.first { account in
                guard let accountID else {
                    return true
                }

                return account.id != accountID
            }?.id
        }
    }
}

private struct HistorySheetContainer<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
                    HistoryCircleButton(
                        systemImage: "xmark",
                        accessibilityLabel: "Cancel",
                        style: .secondary,
                        action: onCancel
                    )

                    Spacer()

                    HistoryCircleButton(
                        systemImage: "checkmark",
                        accessibilityLabel: "Save transaction",
                        style: saveIsEnabled ? .primary : .disabled,
                        action: onSave
                    )
                    .disabled(!saveIsEnabled)
                }

                Text(title)
                    .font(.headline)
                    .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? 2 : 1)
                    .minimumScaleFactor(dynamicTypeSize.isWorthlyAccessibilitySize ? 1 : 0.82)
                    .padding(.horizontal, WorthlySpacing.sheetTitleHorizontal)
            }
            .padding(.top, WorthlySpacing.md)
            .padding(.horizontal, WorthlySpacing.xs)

            ScrollView {
                content
                    .padding(.top, WorthlySpacing.sheetContentTop)
                    .padding(.horizontal, WorthlySpacing.xs)
                    .padding(.bottom, WorthlySpacing.sheetContentBottom)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.horizontal, WorthlySpacing.sheetHorizontal)
    }
}

private struct HistoryCircleButton: View {
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
            WorthlyAccessibleColor.accent
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
            .secondary
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
        .opacity(style == .disabled ? 0.7 : 1)
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct HistoryEditorMenuRow<MenuContent: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
            HStack(spacing: WorthlySpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                if dynamicTypeSize.isWorthlyAccessibilitySize {
                    VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                        Text(title)
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text(value)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)

                    Text(value)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: WorthlySpacing.sm)

                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
            .frame(minHeight: 52)
            .overlay(alignment: .bottom) {
                HistoryEditorSeparator()
                    .padding(.leading, WorthlySpacing.rowSeparatorWithIcon)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct HistoryEditorDateRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var date: Date

    var body: some View {
        DatePicker(
            selection: $date,
            displayedComponents: .date
        ) {
            HStack(spacing: WorthlySpacing.md) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text("Date")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            HistoryEditorSeparator()
                .padding(.leading, WorthlySpacing.rowSeparatorWithIcon)
        }
    }
}

private struct HistoryEditorNotesRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var note: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: WorthlySpacing.md) {
                Image(systemName: "list.clipboard")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text("Notes")
                    .font(.body)

                Spacer()
            }
            .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
            .frame(minHeight: 52)

            TextField("Optional", text: $note, axis: .vertical)
                .font(.body)
                .lineLimit(1...3)
                .textInputAutocapitalization(.sentences)
                .frame(minHeight: 42, alignment: .topLeading)
        }
    }
}

private struct HistoryMissingTransactionSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HistorySheetContainer(
            title: "Transaction not found",
            saveIsEnabled: false,
            onCancel: { dismiss() },
            onSave: {}
        ) {
            Text("Please choose another history record.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct HistoryEditorSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
    }
}

private enum HistoryInputFormatting {
    static func currency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0

        let number = NSDecimalNumber(decimal: amount)
        let value = formatter.string(from: number) ?? number.stringValue

        return "Rp \(value)"
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
}

private extension Account {
    var shortDisplayName: String {
        switch name {
        case "Bank Central Asia":
            "BCA"
        case "Bank Mandiri":
            "Mandiri"
        case "Bank Jago":
            "Jago"
        case "BNI Emergency":
            "BNI"
        case "Cash on hand":
            "Cash"
        default:
            name
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
