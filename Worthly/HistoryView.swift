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
            VStack(alignment: .leading, spacing: 12) {
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
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
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
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "list.bullet.rectangle")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.blue)

            Text("No transactions yet")
                .font(.headline)

            Text("Income, expenses, and account transfers will appear here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
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
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)

            Text("Search")
                .font(.body)
                .foregroundStyle(.secondary)

            Spacer()

            Image(systemName: "mic")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(Color(.secondarySystemGroupedBackground), in: Capsule())
        .accessibilityLabel("Search transactions")
    }
}

private struct JuneSummaryCard: View {
    let total: Decimal
    let count: Int

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 16) {
                Text("June summary")
                    .font(.caption)

                WorthlyAmountText(
                    text: IDRFormatting.signedCompact(total),
                    font: .title3.weight(.bold),
                    color: total < 0 ? .red : .green
                )
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                WorthlyAmountText(text: "\(count)x", font: .caption)

                Text("Transactions")
                    .font(.caption)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

private struct HistorySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
            VStack(spacing: 12) {
                VStack(spacing: 8) {
                    Text("Amount")
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    TextField("Rp 0", text: $amountText)
                        .font(.system(size: 34, weight: .bold))
                        .monospacedDigit()
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

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
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous)
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

private struct HistoryEditorMenuRow<MenuContent: View>: View {
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
                HistoryEditorSeparator()
                    .padding(.leading, 44)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct HistoryEditorDateRow: View {
    @Binding var date: Date

    var body: some View {
        DatePicker(
            selection: $date,
            displayedComponents: .date
        ) {
            HStack(spacing: 14) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text("Date")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .frame(minHeight: 52)
        .overlay(alignment: .bottom) {
            HistoryEditorSeparator()
                .padding(.leading, 44)
        }
    }
}

private struct HistoryEditorNotesRow: View {
    @Binding var note: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                Image(systemName: "list.clipboard")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 30)

                Text("Notes")
                    .font(.body)

                Spacer()
            }
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
