//
//  PlanningEditorSheets.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct MonthlySalaryEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amountTexts: [String]

    let onSave: ([Decimal]) -> Void

    init(incomes: [RecurringIncome], onSave: @escaping ([Decimal]) -> Void) {
        let initialTexts = incomes.map { PlanningInputFormatting.currency($0.amount) }

        _amountTexts = State(initialValue: initialTexts.isEmpty ? [""] : initialTexts)
        self.onSave = onSave
    }

    private var validAmounts: [Decimal] {
        amountTexts.compactMap { text in
            guard let amount = PlanningInputFormatting.decimal(from: text), amount > 0 else {
                return nil
            }

            return amount
        }
    }

    var body: some View {
        PlanningSheetContainer(
            title: "Edit Monthly Salary",
            leadingSystemImage: "xmark",
            leadingAccessibilityLabel: "Cancel editing monthly salary",
            saveIsEnabled: !validAmounts.isEmpty,
            onLeading: { dismiss() },
            onSave: {
                onSave(validAmounts)
                dismiss()
            }
        ) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Amount")
                    .font(.body)
                    .padding(.bottom, WorthlySpacing.sm)

                ForEach(amountTexts.indices, id: \.self) { index in
                    PlanningTextFieldRow(
                        placeholder: "Rp 0,00",
                        text: Binding(
                            get: { amountTexts[index] },
                            set: { amountTexts[index] = $0 }
                        )
                    )
                }

                Button {
                    amountTexts.append("")
                } label: {
                    Text("Add more")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                        .overlay(alignment: .bottom) {
                            PlanningSeparator()
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add another monthly salary amount")
            }
        }
    }
}

struct RecurringExpenseEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var drafts: [RecurringExpenseDraft]

    let onSave: ([RecurringExpense]) -> Void

    @MainActor
    init(expenses: [RecurringExpense], onSave: @escaping ([RecurringExpense]) -> Void) {
        let initialDrafts = expenses.map(RecurringExpenseDraft.init(expense:))

        _drafts = State(initialValue: initialDrafts.isEmpty ? [RecurringExpenseDraft()] : initialDrafts)
        self.onSave = onSave
    }

    private var validExpenses: [RecurringExpense] {
        drafts.compactMap(\.expense)
    }

    var body: some View {
        PlanningSheetContainer(
            title: "Edit Recurring Expenses",
            leadingSystemImage: "xmark",
            leadingAccessibilityLabel: "Cancel editing recurring expenses",
            saveIsEnabled: !validExpenses.isEmpty,
            onLeading: { dismiss() },
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: WorthlySpacing.md) {
                ForEach(drafts.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Expense \(index + 1)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.bottom, WorthlySpacing.sm)

                        PlanningLabeledTextFieldRow(
                            title: "Name",
                            placeholder: "Rent, groceries, subscriptions",
                            text: Binding(
                                get: { drafts[index].name },
                                set: { drafts[index].name = $0 }
                            ),
                            keyboardType: .default,
                            usesMonospacedDigits: false
                        )

                        PlanningLabeledTextFieldRow(
                            title: "Amount",
                            placeholder: "Rp 0",
                            text: Binding(
                                get: { drafts[index].amountText },
                                set: { drafts[index].amountText = $0 }
                            )
                        )

                        PlanningLabeledTextFieldRow(
                            title: "Day of month",
                            placeholder: "1",
                            text: Binding(
                                get: { drafts[index].dayText },
                                set: { drafts[index].dayText = $0 }
                            ),
                            keyboardType: .numberPad
                        )
                    }
                }

                Button {
                    drafts.append(RecurringExpenseDraft())
                } label: {
                    Label("Add more", systemImage: "plus")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                        .overlay(alignment: .bottom) {
                            PlanningSeparator()
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add another recurring expense")
            }
        }
    }

    private func save() {
        let expenses = validExpenses

        guard !expenses.isEmpty else {
            return
        }

        onSave(expenses)
        dismiss()
    }
}

struct TargetNetWorthEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amountText: String

    let onSave: (Decimal) -> Void

    init(target: Decimal, onSave: @escaping (Decimal) -> Void) {
        _amountText = State(initialValue: target > 0 ? PlanningInputFormatting.currency(target) : "")
        self.onSave = onSave
    }

    private var amount: Decimal? {
        PlanningInputFormatting.decimal(from: amountText)
    }

    private var canSave: Bool {
        guard let amount else {
            return false
        }

        return amount > 0
    }

    var body: some View {
        PlanningSheetContainer(
            title: "Edit Target Net Worth",
            leadingSystemImage: "xmark",
            leadingAccessibilityLabel: "Cancel editing target net worth",
            saveIsEnabled: canSave,
            onLeading: { dismiss() },
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                PlanningLabeledTextFieldRow(
                    title: "Target Amount",
                    placeholder: "Rp 0",
                    text: $amountText
                )

                Text("Used to compare your projected net worth against a goal.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func save() {
        guard let amount, amount > 0 else {
            return
        }

        onSave(amount)
        dismiss()
    }
}

struct InvestmentEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var investments: [SBNInvestment]
    @State private var route: InvestmentEditorRoute = .list

    let referenceDate: Date
    let onAddInvestment: (SBNInvestment) -> Void

    init(
        investments: Binding<[SBNInvestment]>,
        referenceDate: Date,
        onAddInvestment: @escaping (SBNInvestment) -> Void
    ) {
        _investments = investments
        self.referenceDate = referenceDate
        self.onAddInvestment = onAddInvestment
    }

    var body: some View {
        switch route {
        case .list:
            PlanningSheetContainer(
                title: "Edit Investment",
                leadingSystemImage: "xmark",
                leadingAccessibilityLabel: "Cancel editing investment",
                saveIsEnabled: false,
                onLeading: { dismiss() },
                onSave: {}
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    if investments.isEmpty {
                        PlanningEditorEmptyState(
                            systemImage: "chart.line.uptrend.xyaxis",
                            title: "No investments yet",
                            message: "Add an investment to include its estimated return in your projection.",
                            buttonTitle: "Add investment",
                            buttonSystemImage: "plus"
                        ) {
                            route = .add
                        }
                    } else {
                        Text("Which one to edit")
                            .font(.body)
                            .padding(.bottom, WorthlySpacing.sm)

                        ForEach(investments) { investment in
                            PlanningSelectionRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: investment.name
                            ) {
                                route = .detail(investment.id)
                            }
                        }
                    }
                }
            }
        case .detail(let id):
            if let index = investments.firstIndex(where: { $0.id == id }) {
                InvestmentDetailEditorSheet(
                    investment: $investments[index],
                    onBack: { route = .list },
                    onDone: { dismiss() }
                )
            } else {
                PlanningMissingSelectionSheet(
                    title: "Investment not found",
                    onClose: { dismiss() }
                )
            }
        case .add:
            AddAssetEditorSheet(
                title: "Add Investment",
                initialKind: .sbnInvestment,
                allowedKinds: [.sbnInvestment],
                referenceDate: referenceDate,
                onSaveAccount: { _ in },
                onSaveInvestment: { onAddInvestment($0) },
                onSaveDebt: { _ in }
            )
        }
    }
}

private enum InvestmentEditorRoute {
    case list
    case detail(UUID)
    case add
}

private struct InvestmentDetailEditorSheet: View {
    @Binding var investment: SBNInvestment
    @State private var principalText: String
    @State private var interestText: String
    @State private var durationText: String

    let onBack: () -> Void
    let onDone: () -> Void

    init(
        investment: Binding<SBNInvestment>,
        onBack: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        _investment = investment
        _principalText = State(initialValue: PlanningInputFormatting.currency(investment.wrappedValue.principal))
        _interestText = State(initialValue: PlanningInputFormatting.number(investment.wrappedValue.annualInterestRate))
        _durationText = State(initialValue: "\(investment.wrappedValue.durationMonths)")
        self.onBack = onBack
        self.onDone = onDone
    }

    private var principal: Decimal? {
        PlanningInputFormatting.decimal(from: principalText)
    }

    private var interest: Decimal? {
        PlanningInputFormatting.decimal(from: interestText)
    }

    private var duration: Int? {
        PlanningInputFormatting.integer(from: durationText)
    }

    private var canSave: Bool {
        guard let principal, let interest, let duration else {
            return false
        }

        return principal > 0 && interest >= 0 && duration > 0
    }

    var body: some View {
        PlanningSheetContainer(
            title: "Edit \(investment.name)",
            leadingSystemImage: "chevron.left",
            leadingAccessibilityLabel: "Back to investment list",
            saveIsEnabled: canSave,
            onLeading: onBack,
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: 0) {
                PlanningLabeledTextFieldRow(
                    title: "Investment Value",
                    placeholder: "Rp 0,00",
                    text: $principalText
                )

                PlanningLabeledTextFieldRow(
                    title: "Interest p.a. (%)",
                    placeholder: "0",
                    text: $interestText
                )

                PlanningLabeledTextFieldRow(
                    title: "Duration (Months)",
                    placeholder: "0",
                    text: $durationText
                )
            }
        }
    }

    private func save() {
        guard let principal, let interest, let duration else {
            return
        }

        investment.principal = principal
        investment.annualInterestRate = interest
        investment.durationMonths = duration
        onDone()
    }
}

struct DebtEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var debts: [Debt]
    @State private var route: DebtEditorRoute = .list

    let referenceDate: Date
    let onAddDebt: (Debt) -> Void

    init(
        debts: Binding<[Debt]>,
        referenceDate: Date,
        onAddDebt: @escaping (Debt) -> Void
    ) {
        _debts = debts
        self.referenceDate = referenceDate
        self.onAddDebt = onAddDebt
    }

    var body: some View {
        switch route {
        case .list:
            PlanningSheetContainer(
                title: "Edit Liability",
                leadingSystemImage: "xmark",
                leadingAccessibilityLabel: "Cancel editing liability",
                saveIsEnabled: false,
                onLeading: { dismiss() },
                onSave: {}
            ) {
                VStack(alignment: .leading, spacing: 0) {
                    if debts.isEmpty {
                        PlanningEditorEmptyState(
                            systemImage: "creditcard",
                            title: "No liabilities yet",
                            message: "Add a liability to include its monthly payment in your projection.",
                            buttonTitle: "Add liability",
                            buttonSystemImage: "plus"
                        ) {
                            route = .add
                        }
                    } else {
                        Text("Which one to edit")
                            .font(.body)
                            .padding(.bottom, WorthlySpacing.sm)

                        ForEach(debts) { debt in
                            PlanningSelectionRow(
                                icon: debt.editorIcon,
                                title: debt.name
                            ) {
                                route = .detail(debt.id)
                            }
                        }
                    }
                }
            }
        case .detail(let id):
            if let index = debts.firstIndex(where: { $0.id == id }) {
                DebtDetailEditorSheet(
                    debt: $debts[index],
                    onBack: { route = .list },
                    onDone: { dismiss() }
                )
            } else {
                PlanningMissingSelectionSheet(
                    title: "Liability not found",
                    onClose: { dismiss() }
                )
            }
        case .add:
            AddAssetEditorSheet(
                title: "Add Liability",
                initialKind: .liability,
                allowedKinds: [.liability],
                referenceDate: referenceDate,
                onSaveAccount: { _ in },
                onSaveInvestment: { _ in },
                onSaveDebt: { onAddDebt($0) }
            )
        }
    }
}

private enum DebtEditorRoute {
    case list
    case detail(UUID)
    case add
}

private struct DebtDetailEditorSheet: View {
    @Binding var debt: Debt
    @State private var amountText: String
    @State private var interestText: String
    @State private var durationText: String
    @State private var startDate: Date

    let onBack: () -> Void
    let onDone: () -> Void

    init(
        debt: Binding<Debt>,
        onBack: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        _debt = debt
        _amountText = State(initialValue: PlanningInputFormatting.currency(debt.wrappedValue.remainingAmount))
        _interestText = State(initialValue: PlanningInputFormatting.number(debt.wrappedValue.annualInterestRate))
        _durationText = State(initialValue: "\(debt.wrappedValue.durationMonths)")
        _startDate = State(initialValue: debt.wrappedValue.startDate)
        self.onBack = onBack
        self.onDone = onDone
    }

    private var amount: Decimal? {
        PlanningInputFormatting.decimal(from: amountText)
    }

    private var interest: Decimal? {
        PlanningInputFormatting.decimal(from: interestText)
    }

    private var duration: Int? {
        PlanningInputFormatting.integer(from: durationText)
    }

    private var canSave: Bool {
        guard let amount, let interest, let duration else {
            return false
        }

        return amount > 0 && interest >= 0 && duration > 0
    }

    var body: some View {
        PlanningSheetContainer(
            title: "Edit \(debt.name)",
            leadingSystemImage: "chevron.left",
            leadingAccessibilityLabel: "Back to liability list",
            saveIsEnabled: canSave,
            onLeading: onBack,
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: 0) {
                PlanningLabeledTextFieldRow(
                    title: "Liability Value",
                    placeholder: "Rp 0,00",
                    text: $amountText
                )

                PlanningLabeledTextFieldRow(
                    title: "Interest p.a. (%)",
                    placeholder: "0",
                    text: $interestText
                )

                PlanningLabeledTextFieldRow(
                    title: "Duration (Months)",
                    placeholder: "0",
                    text: $durationText
                )

                PlanningMonthYearFieldRow(
                    title: "Since",
                    date: $startDate
                )
            }
        }
    }

    private func save() {
        guard let amount, let interest, let duration else {
            return
        }

        debt.remainingAmount = amount
        debt.annualInterestRate = interest
        debt.durationMonths = duration
        debt.startDate = startDate
        onDone()
    }
}

private struct PlanningSheetContainer<Content: View>: View {
    let title: String
    let leadingSystemImage: String
    let leadingAccessibilityLabel: String
    let saveIsEnabled: Bool
    let onLeading: () -> Void
    let onSave: () -> Void
    let content: Content

    init(
        title: String,
        leadingSystemImage: String,
        leadingAccessibilityLabel: String,
        saveIsEnabled: Bool,
        onLeading: @escaping () -> Void,
        onSave: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.leadingSystemImage = leadingSystemImage
        self.leadingAccessibilityLabel = leadingAccessibilityLabel
        self.saveIsEnabled = saveIsEnabled
        self.onLeading = onLeading
        self.onSave = onSave
        self.content = content()
    }

    var body: some View {
        WorthlyFullScreenEditorContainer(
            title: title,
            leadingSystemImage: leadingSystemImage,
            leadingAccessibilityLabel: leadingAccessibilityLabel,
            saveAccessibilityLabel: "Save changes",
            saveIsEnabled: saveIsEnabled,
            onLeading: onLeading,
            onSave: onSave
        ) {
            content
        }
    }
}

private struct PlanningSelectionRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            WorthlyDisclosureRow(
                icon: icon,
                title: title,
                rowMinHeight: 60,
                separatorLeadingInset: 56
            )
        }
        .buttonStyle(.plain)
    }
}

private struct PlanningEditorEmptyState: View {
    let systemImage: String
    let title: String
    let message: String
    let buttonTitle: String
    let buttonSystemImage: String
    let action: () -> Void

    var body: some View {
        WorthlyEmptyStateCard(
            systemImage: systemImage,
            title: title,
            message: message,
            buttonTitle: buttonTitle,
            buttonSystemImage: buttonSystemImage,
            action: action
        )
    }
}

private struct PlanningMissingSelectionSheet: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        PlanningSheetContainer(
            title: title,
            leadingSystemImage: "xmark",
            leadingAccessibilityLabel: "Close",
            saveIsEnabled: false,
            onLeading: onClose,
            onSave: {}
        ) {
            Text("Please choose another item.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
