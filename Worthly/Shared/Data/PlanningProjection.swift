//
//  PlanningProjection.swift
//  Worthly
//
//  Created by Codex on 2026/06/21.
//

import Foundation

struct PlanningProjectionSummary {
    let currentNetWorth: Decimal
    let projectedNetWorth: Decimal
    let netWorthTarget: Decimal
    let gapToTarget: Decimal
    let requiredMonthlySurplus: Decimal
    let months: [PlanningProjectionMonth]

    let totalIncome: Decimal
    let totalInvestmentReturns: Decimal
    let totalRecurringExpenses: Decimal
    let totalLiabilityPayments: Decimal
    let totalLiabilityInterest: Decimal
    let totalLiabilityPrincipal: Decimal

    var isOnTrack: Bool {
        netWorthTarget > 0 && gapToTarget >= 0
    }

    var hasTarget: Bool {
        netWorthTarget > 0
    }

    var monthCount: Int {
        max(months.count, 1)
    }

    var averageMonthlyIncome: Decimal {
        totalIncome / Decimal(monthCount)
    }

    var averageMonthlyInvestmentReturns: Decimal {
        totalInvestmentReturns / Decimal(monthCount)
    }

    var averageMonthlyRecurringExpenses: Decimal {
        totalRecurringExpenses / Decimal(monthCount)
    }

    var averageMonthlyLiabilityPayments: Decimal {
        totalLiabilityPayments / Decimal(monthCount)
    }

    var averageMonthlyLiabilityInterest: Decimal {
        totalLiabilityInterest / Decimal(monthCount)
    }
}

struct PlanningProjectionMonth: Identifiable {
    var id: Date { monthStart }

    let monthStart: Date
    let income: Decimal
    let investmentReturns: Decimal
    let recurringExpenses: Decimal
    let liabilityPayments: Decimal
    let liabilityInterest: Decimal
    let liabilityPrincipal: Decimal
    let cashSurplus: Decimal
    let endingLiquidAssets: Decimal
    let endingInvestmentPrincipal: Decimal
    let endingLiabilityBalance: Decimal
    let endingNetWorth: Decimal
}

enum PlanningProjectionEngine {
    static func project(
        referenceDate: Date,
        projectionHorizon: Date,
        liquidAssets: Decimal,
        investmentPrincipal: Decimal,
        debts: [Debt],
        recurringIncomes: [RecurringIncome],
        recurringExpenses: [RecurringExpense],
        investments: [SBNInvestment],
        netWorthTarget: Decimal,
        calendar: Calendar = .worthly
    ) -> PlanningProjectionSummary {
        let initialLiabilityBalance = debts.reduce(Decimal(0)) { $0 + $1.remainingAmount }
        let currentNetWorth = liquidAssets + investmentPrincipal - initialLiabilityBalance
        let monthStarts = projectionMonths(
            from: referenceDate,
            through: projectionHorizon,
            calendar: calendar
        )

        var liquidBalance = liquidAssets
        var debtStates = debts.map { PlanningDebtProjectionState(debt: $0, calendar: calendar) }
        var months: [PlanningProjectionMonth] = []

        var totalIncome: Decimal = 0
        var totalInvestmentReturns: Decimal = 0
        var totalRecurringExpenses: Decimal = 0
        var totalLiabilityPayments: Decimal = 0
        var totalLiabilityInterest: Decimal = 0
        var totalLiabilityPrincipal: Decimal = 0

        for monthStart in monthStarts {
            let income = recurringIncomes.reduce(Decimal(0)) { total, income in
                guard shouldCountOccurrence(
                    day: income.payday,
                    inMonthStarting: monthStart,
                    referenceDate: referenceDate,
                    projectionHorizon: projectionHorizon,
                    calendar: calendar
                ) else {
                    return total
                }

                return total + income.amount
            }

            let investmentReturns = investments.reduce(Decimal(0)) { total, investment in
                guard shouldCountOccurrence(
                    day: calendar.component(.day, from: investment.startDate),
                    inMonthStarting: monthStart,
                    referenceDate: referenceDate,
                    projectionHorizon: projectionHorizon,
                    activeFrom: investment.startDate,
                    activeUntil: investment.maturityDate(using: calendar),
                    calendar: calendar
                ) else {
                    return total
                }

                return total + investment.estimatedMonthlyCoupon
            }

            let expenseTotal = recurringExpenses.reduce(Decimal(0)) { total, expense in
                guard shouldCountOccurrence(
                    day: expense.dayOfMonth,
                    inMonthStarting: monthStart,
                    referenceDate: referenceDate,
                    projectionHorizon: projectionHorizon,
                    calendar: calendar
                ) else {
                    return total
                }

                return total + expense.amount
            }

            var liabilityPayments: Decimal = 0
            var liabilityInterest: Decimal = 0
            var liabilityPrincipal: Decimal = 0

            for index in debtStates.indices {
                guard shouldCountOccurrence(
                    day: debtStates[index].paymentDay,
                    inMonthStarting: monthStart,
                    referenceDate: referenceDate,
                    projectionHorizon: projectionHorizon,
                    calendar: calendar
                ) else {
                    continue
                }

                let payment = debtStates[index].advanceOnePayment()
                liabilityPayments += payment.total
                liabilityInterest += payment.interest
                liabilityPrincipal += payment.principal
            }

            let cashSurplus = income + investmentReturns - expenseTotal - liabilityPayments
            liquidBalance += cashSurplus
            let endingLiabilityBalance = debtStates.reduce(Decimal(0)) { $0 + $1.remainingBalance }
            let endingNetWorth = liquidBalance + investmentPrincipal - endingLiabilityBalance

            totalIncome += income
            totalInvestmentReturns += investmentReturns
            totalRecurringExpenses += expenseTotal
            totalLiabilityPayments += liabilityPayments
            totalLiabilityInterest += liabilityInterest
            totalLiabilityPrincipal += liabilityPrincipal

            months.append(
                PlanningProjectionMonth(
                    monthStart: monthStart,
                    income: income,
                    investmentReturns: investmentReturns,
                    recurringExpenses: expenseTotal,
                    liabilityPayments: liabilityPayments,
                    liabilityInterest: liabilityInterest,
                    liabilityPrincipal: liabilityPrincipal,
                    cashSurplus: cashSurplus,
                    endingLiquidAssets: liquidBalance,
                    endingInvestmentPrincipal: investmentPrincipal,
                    endingLiabilityBalance: endingLiabilityBalance,
                    endingNetWorth: endingNetWorth
                )
            )
        }

        let projectedNetWorth = months.last?.endingNetWorth ?? currentNetWorth
        let gapToTarget = projectedNetWorth - netWorthTarget
        let requiredMonthlySurplus = netWorthTarget > 0 && gapToTarget < 0
            ? (-gapToTarget / Decimal(max(months.count, 1)))
            : 0

        return PlanningProjectionSummary(
            currentNetWorth: currentNetWorth,
            projectedNetWorth: projectedNetWorth,
            netWorthTarget: netWorthTarget,
            gapToTarget: gapToTarget,
            requiredMonthlySurplus: requiredMonthlySurplus,
            months: months,
            totalIncome: totalIncome,
            totalInvestmentReturns: totalInvestmentReturns,
            totalRecurringExpenses: totalRecurringExpenses,
            totalLiabilityPayments: totalLiabilityPayments,
            totalLiabilityInterest: totalLiabilityInterest,
            totalLiabilityPrincipal: totalLiabilityPrincipal
        )
    }

    private static func projectionMonths(
        from referenceDate: Date,
        through projectionHorizon: Date,
        calendar: Calendar
    ) -> [Date] {
        guard projectionHorizon >= referenceDate,
              var monthCursor = calendar.dateInterval(of: .month, for: referenceDate)?.start,
              let endMonth = calendar.dateInterval(of: .month, for: projectionHorizon)?.start else {
            return []
        }

        var months: [Date] = []

        while monthCursor <= endMonth {
            months.append(monthCursor)
            monthCursor = calendar.date(byAdding: .month, value: 1, to: monthCursor) ?? endMonth.addingTimeInterval(1)
        }

        return months
    }

    private static func shouldCountOccurrence(
        day: Int,
        inMonthStarting monthStart: Date,
        referenceDate: Date,
        projectionHorizon: Date,
        activeFrom: Date? = nil,
        activeUntil: Date? = nil,
        calendar: Calendar
    ) -> Bool {
        let occurrence = clampedDate(day: day, inMonthStarting: monthStart, calendar: calendar)
        let lowerBound = [referenceDate, activeFrom].compactMap { $0 }.max() ?? referenceDate
        let upperBound = [projectionHorizon, activeUntil].compactMap { $0 }.min() ?? projectionHorizon

        return occurrence > referenceDate
            && occurrence >= lowerBound
            && occurrence <= upperBound
    }

    private static func clampedDate(day: Int, inMonthStarting monthStart: Date, calendar: Calendar) -> Date {
        let dayRange = calendar.range(of: .day, in: .month, for: monthStart)
        let clampedDay = min(max(day, 1), dayRange?.count ?? day)
        let components = calendar.dateComponents([.year, .month], from: monthStart)

        return DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: components.year,
            month: components.month,
            day: clampedDay,
            hour: 12
        ).date ?? monthStart
    }
}

private struct PlanningDebtProjectionState {
    let paymentDay: Int
    let scheduledPayment: Decimal
    let monthlyRate: Decimal
    var remainingBalance: Decimal
    var remainingPayments: Int

    init(debt: Debt, calendar: Calendar) {
        paymentDay = calendar.component(.day, from: debt.startDate)
        scheduledPayment = debt.estimatedMonthlyInstallment
        monthlyRate = debt.annualInterestRate / 100 / 12
        remainingBalance = debt.remainingAmount
        remainingPayments = max(debt.durationMonths, 0)
    }

    mutating func advanceOnePayment() -> PlanningLiabilityPayment {
        guard remainingBalance > 0, remainingPayments > 0 else {
            return PlanningLiabilityPayment(total: 0, interest: 0, principal: 0)
        }

        let interest = max(remainingBalance * monthlyRate, 0)
        let uncappedPayment = min(scheduledPayment, remainingBalance + interest)
        let principal = min(max(uncappedPayment - interest, 0), remainingBalance)
        let total = principal + interest

        remainingBalance -= principal
        remainingPayments -= 1

        return PlanningLiabilityPayment(total: total, interest: interest, principal: principal)
    }
}

private struct PlanningLiabilityPayment {
    let total: Decimal
    let interest: Decimal
    let principal: Decimal
}
