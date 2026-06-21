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

    private var monthlyRecurringExpenses: Decimal {
        store.monthlyRecurringExpenses
    }

    private var monthlyDebtInstallment: Decimal {
        store.monthlyDebtInstallment
    }

    private var planningProjection: PlanningProjectionSummary {
        store.planningProjection
    }

    private var projectedNetWorth: Decimal {
        store.projectedNetWorth
    }

    private var gapToTarget: Decimal {
        store.gapToTarget
    }

    private var netWorthTarget: Decimal {
        store.netWorthTarget
    }

    private var projectionRange: ClosedRange<Date> {
        let start = store.referenceDate
        let end = Calendar.worthly.date(byAdding: .year, value: 10, to: start) ?? start

        return start...end
    }

    private var projectionHorizon: Binding<Date> {
        Binding(
            get: { store.projectionHorizon },
            set: { store.projectionHorizon = clampedProjectionDate($0) }
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
            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                if store.hasStartedMoneyMap {
                    ProjectionCard(
                        horizon: store.projectionHorizon,
                        projectedNetWorth: projectedNetWorth
                    )

                    TargetReadinessCard(
                        summary: planningProjection,
                        horizon: store.projectionHorizon
                    )

                    GapCard(
                        gap: gapToTarget,
                        target: netWorthTarget
                    )

                    PlanningMonthlyBreakdownCard(summary: planningProjection)
                } else {
                    PlanningEmptyStateCard()
                }

                Text("Assumptions")
                    .font(.headline)
                    .padding(.top, WorthlySpacing.xxs)

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
                        activeEditor = .expenses
                    } label: {
                        WorthlyDisclosureRow(
                            title: "Recurring expenses",
                            value: IDRFormatting.compact(monthlyRecurringExpenses)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        activeEditor = .investments
                    } label: {
                        WorthlyDisclosureRow(
                            title: "Investment returns (monthly)",
                            value: IDRFormatting.compact(monthlySbnCoupon)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        activeEditor = .debts
                    } label: {
                        WorthlyDisclosureRow(
                            title: "Liability payments (monthly)",
                            value: IDRFormatting.compact(monthlyDebtInstallment)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        activeEditor = .target
                    } label: {
                        WorthlyDisclosureRow(
                            title: "Target net worth",
                            value: netWorthTarget > 0 ? IDRFormatting.compact(netWorthTarget) : "Not set",
                            valueUsesMonospacedDigits: netWorthTarget > 0
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
                        ProjectionHorizonCalendar(
                            selection: projectionHorizon,
                            range: projectionRange
                        )
                            .padding(.top, WorthlySpacing.xs)
                            .padding(.bottom, WorthlySpacing.sm)
                            .transition(calendarTransition)
                    }
                }
                .padding(.top, WorthlySpacing.sm)
            }
            .padding(.horizontal, WorthlySpacing.screenHorizontal)
            .padding(.top, WorthlySpacing.xs)
            .padding(.bottom, WorthlySpacing.pageBottom)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Planning")
        .navigationBarTitleDisplayMode(.large)
        .fullScreenCover(item: $activeEditor) { editor in
            switch editor {
            case .salary:
                MonthlySalaryEditorSheet(
                    incomes: store.recurringIncomes,
                    onSave: { store.saveSalaryAmounts($0) }
                )
            case .expenses:
                RecurringExpenseEditorSheet(
                    expenses: store.recurringExpenses,
                    onSave: { store.saveRecurringExpenses($0) }
                )
            case .investments:
                InvestmentEditorSheet(
                    investments: investments,
                    referenceDate: store.referenceDate,
                    onAddInvestment: { store.addInvestment($0) }
                )
            case .debts:
                DebtEditorSheet(
                    debts: debts,
                    referenceDate: store.referenceDate,
                    onAddDebt: { store.addDebt($0) }
                )
            case .target:
                TargetNetWorthEditorSheet(
                    target: store.netWorthTarget,
                    onSave: { store.netWorthTarget = $0 }
                )
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

    private func clampedProjectionDate(_ date: Date) -> Date {
        min(max(date, projectionRange.lowerBound), projectionRange.upperBound)
    }
}

private enum PlanningEditor: String, Identifiable {
    case salary
    case expenses
    case investments
    case debts
    case target

    var id: String {
        rawValue
    }
}

#Preview {
    NavigationStack {
        PlanningView()
    }
}
