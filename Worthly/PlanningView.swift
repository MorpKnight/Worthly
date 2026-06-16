//
//  PlanningView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct PlanningView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let store: FinanceStore

    @State private var activeEditor: PlanningEditor?
    @State private var showsProjectionCalendar = false

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    private var monthlySalary: Decimal {
        store.monthlySalary
    }

    private var monthlySbnCoupon: Decimal {
        store.monthlySbnCoupon
    }

    private var monthlyDebtInstallment: Decimal {
        store.monthlyDebtInstallment
    }

    private var projectedNetWorth: Decimal {
        store.projectedNetWorth
    }

    private var gapToTarget: Decimal {
        store.gapToTarget
    }

    private var projectionHorizon: Binding<Date> {
        Binding(
            get: { store.projectionHorizon },
            set: { store.projectionHorizon = $0 }
        )
    }

    private var investments: Binding<[SBNInvestment]> {
        Binding(
            get: { store.sbnInvestments },
            set: { store.sbnInvestments = $0 }
        )
    }

    private var debts: Binding<[Debt]> {
        Binding(
            get: { store.debts },
            set: { store.debts = $0 }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ProjectionCard(
                    horizon: store.projectionHorizon,
                    projectedNetWorth: projectedNetWorth
                )

                GapCard(gap: gapToTarget)

                Text("Assumptions")
                    .font(.headline)
                    .padding(.top, 2)

                VStack(spacing: 0) {
                    Button {
                        activeEditor = .salary
                    } label: {
                        WorthlyDisclosureRow(
                            title: "Monthly salary",
                            value: IDRFormatting.compact(monthlySalary)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        activeEditor = .investments
                    } label: {
                        WorthlyDisclosureRow(
                            title: "SBN coupons (monthly)",
                            value: IDRFormatting.compact(monthlySbnCoupon)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        activeEditor = .debts
                    } label: {
                        WorthlyDisclosureRow(
                            title: "Debt installments (monthly)",
                            value: IDRFormatting.compact(monthlyDebtInstallment)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        toggleProjectionCalendar()
                    } label: {
                        ProjectionHorizonDisclosureRow(
                            value: WorthlyDateFormatting.projectionHorizon(store.projectionHorizon),
                            isExpanded: showsProjectionCalendar
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Shows or hides the projection date picker")

                    if showsProjectionCalendar {
                        ProjectionHorizonCalendar(selection: projectionHorizon)
                            .padding(.top, 8)
                            .padding(.bottom, 10)
                            .transition(calendarTransition)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Planning")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorthlyToolbarIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "Add planning item"
                ) {
                    // Static first pass; planning edit flow comes later.
                }
            }
        }
        .sheet(item: $activeEditor) { editor in
            switch editor {
            case .salary:
                MonthlySalaryEditorSheet(
                    incomes: store.recurringIncomes,
                    onSave: { store.saveSalaryAmounts($0) }
                )
                .presentationDetents([.height(390), .medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
                .presentationBackground(.regularMaterial)
            case .investments:
                InvestmentEditorSheet(investments: investments)
                    .presentationDetents([.height(420), .medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
                    .presentationBackground(.regularMaterial)
            case .debts:
                DebtEditorSheet(debts: debts)
                    .presentationDetents([.height(500), .medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(28)
                    .presentationBackground(.regularMaterial)
            }
        }
    }

    private var calendarTransition: AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .move(edge: .top))
    }

    private func toggleProjectionCalendar() {
        if reduceMotion {
            showsProjectionCalendar.toggle()
        } else {
            withAnimation(.snappy(duration: 0.22)) {
                showsProjectionCalendar.toggle()
            }
        }
    }
}

private enum PlanningEditor: String, Identifiable {
    case salary
    case investments
    case debts

    var id: String {
        rawValue
    }
}

private struct ProjectionCard: View {
    let horizon: Date
    let projectedNetWorth: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Projected \(WorthlyDateFormatting.projectionHorizon(horizon))")
                .font(.subheadline)

            WorthlyAmountText(
                text: IDRFormatting.full(projectedNetWorth),
                font: .title2.weight(.bold),
                minimumScaleFactor: 0.78
            )

            Text("Estimate based on recurring salary, SBN coupon, and debt installment")
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

private struct GapCard: View {
    let gap: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gap to target")
                .font(.subheadline)

            WorthlyAmountText(
                text: IDRFormatting.signedCompact(gap),
                font: .title2.weight(.bold),
                color: gap < 0 ? .red : .green,
                minimumScaleFactor: 0.78
            )
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

private struct ProjectionHorizonDisclosureRow: View {
    let value: String
    let isExpanded: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text("Projection horizon")
                .font(.body)
                .foregroundStyle(.primary)

            Spacer(minLength: 12)

            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .frame(width: 16)
        }
        .frame(minHeight: 60)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Projection horizon, \(value)")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
    }
}

private struct ProjectionHorizonCalendar: View {
    @Binding var selection: Date

    var body: some View {
        DatePicker(
            "Projection horizon",
            selection: $selection,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(WorthlyCardBackground(cornerRadius: 12))
        .accessibilityLabel("Projection horizon calendar")
    }
}

private struct MonthlySalaryEditorSheet: View {
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
                    .padding(.bottom, 12)

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
                        .foregroundStyle(.tertiary)
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

private struct InvestmentEditorSheet: View {
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
                        .padding(.bottom, 10)

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

private struct DebtEditorSheet: View {
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
                        .padding(.bottom, 10)

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

private struct PlanningTextFieldRow: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .font(.body.weight(.semibold))
            .monospacedDigit()
            .keyboardType(.decimalPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .frame(minHeight: 54, alignment: .leading)
            .overlay(alignment: .bottom) {
                PlanningSeparator()
            }
    }
}

private struct PlanningLabeledTextFieldRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)

            PlanningTextFieldRow(placeholder: placeholder, text: $text)
        }
        .padding(.bottom, 12)
    }
}

private struct PlanningMonthYearFieldRow: View {
    let title: String
    @Binding var date: Date

    private let years = Array(2020...2032)
    private let months = Array(1...12)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)

            Menu {
                ForEach(years, id: \.self) { year in
                    Menu("\(year)") {
                        ForEach(months, id: \.self) { month in
                            Button(PlanningInputFormatting.monthName(month)) {
                                date = PlanningInputFormatting.date(year: year, month: month)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(PlanningInputFormatting.monthYear(date))
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .frame(minHeight: 54)
                .overlay(alignment: .bottom) {
                    PlanningSeparator()
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 12)
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

private struct PlanningSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
    }
}

private enum PlanningInputFormatting {
    static func currency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        let number = NSDecimalNumber(decimal: amount)
        let value = formatter.string(from: number) ?? number.stringValue

        return "Rp \(value)"
    }

    static func number(_ amount: Decimal) -> String {
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

        return Int(digits)
    }

    static func monthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM yyyy"

        return formatter.string(from: date)
    }

    static func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.monthSymbols[max(min(month - 1, 11), 0)]
    }

    static func date(year: Int, month: Int) -> Date {
        let calendar = Calendar(identifier: .gregorian)

        return calendar.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
    }
}

private extension Debt {
    var editorIcon: String {
        let lowercasedName = name.lowercased()

        if lowercasedName.contains("kpr") || lowercasedName.contains("home") || lowercasedName.contains("rumah") {
            return "house"
        }

        if lowercasedName.contains("car") || lowercasedName.contains("mobil") {
            return "car"
        }

        return "creditcard"
    }
}

#Preview {
    NavigationStack {
        PlanningView()
    }
}
