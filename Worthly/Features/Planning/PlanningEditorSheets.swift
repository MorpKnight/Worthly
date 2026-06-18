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

struct InvestmentEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var investments: [SBNInvestment]
    @State private var route: InvestmentEditorRoute = .list

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
        }
    }
}

private enum InvestmentEditorRoute {
    case list
    case detail(UUID)
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

    var body: some View {
        switch route {
        case .list:
            PlanningSheetContainer(
                title: "Edit Debt",
                leadingSystemImage: "xmark",
                leadingAccessibilityLabel: "Cancel editing debt",
                saveIsEnabled: false,
                onLeading: { dismiss() },
                onSave: {}
            ) {
                VStack(alignment: .leading, spacing: 0) {
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
        case .detail(let id):
            if let index = debts.firstIndex(where: { $0.id == id }) {
                DebtDetailEditorSheet(
                    debt: $debts[index],
                    onBack: { route = .list },
                    onDone: { dismiss() }
                )
            } else {
                PlanningMissingSelectionSheet(
                    title: "Debt not found",
                    onClose: { dismiss() }
                )
            }
        }
    }
}

private enum DebtEditorRoute {
    case list
    case detail(UUID)
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
            leadingAccessibilityLabel: "Back to debt list",
            saveIsEnabled: canSave,
            onLeading: onBack,
            onSave: save
        ) {
            VStack(alignment: .leading, spacing: 0) {
                PlanningLabeledTextFieldRow(
                    title: "Debt Value",
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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    PlanningSheetCircleButton(
                        systemImage: leadingSystemImage,
                        accessibilityLabel: leadingAccessibilityLabel,
                        style: .secondary,
                        action: onLeading
                    )

                    Spacer()

                    PlanningSheetCircleButton(
                        systemImage: "checkmark",
                        accessibilityLabel: "Save changes",
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

private struct PlanningSheetCircleButton: View {
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
