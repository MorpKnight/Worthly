//
//  HistoryEditorSheets.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct HistoryTransactionEditorSheet: View {
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

struct HistoryMissingTransactionSheet: View {
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
