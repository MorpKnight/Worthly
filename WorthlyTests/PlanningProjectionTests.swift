//
//  PlanningProjectionTests.swift
//  WorthlyTests
//
//  Created by Codex on 2026/06/21.
//

import XCTest
@testable import Worthly

final class PlanningProjectionTests: XCTestCase {
    func testOldSnapshotJSONWithoutRecurringExpensesDecodesSafely() throws {
        let data = """
        {
          "referenceDate": "2026-06-01T00:00:00Z",
          "projectionHorizon": "2026-12-31T00:00:00Z",
          "accounts": [],
          "transactions": [],
          "sbnInvestments": [],
          "debts": [],
          "recurringIncomes": [],
          "checklistActions": [],
          "netWorthTarget": 0,
          "hasAnsweredLiabilitySetup": false,
          "hasCompletedOnboarding": false
        }
        """.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let snapshot = try decoder.decode(FinanceSnapshot.self, from: data)

        XCTAssertTrue(snapshot.recurringExpenses.isEmpty)
    }

    func testZeroInterestLiabilityReducesPrincipalWithoutInterestExpense() {
        let debt = Debt(
            id: UUID(),
            name: "Installment",
            remainingAmount: 120,
            annualInterestRate: 0,
            durationMonths: 12,
            startDate: date(month: 6, day: 15)
        )

        let summary = PlanningProjectionEngine.project(
            referenceDate: date(month: 6, day: 1),
            projectionHorizon: date(month: 6, day: 30),
            liquidAssets: 1_000,
            investmentPrincipal: 0,
            debts: [debt],
            recurringIncomes: [],
            recurringExpenses: [],
            investments: [],
            netWorthTarget: 0
        )

        XCTAssertEqual(summary.months.first?.liabilityInterest, 0)
        XCTAssertEqual(summary.months.first?.liabilityPrincipal, 10)
        XCTAssertEqual(summary.projectedNetWorth, 880)
    }

    func testInterestBearingLiabilitySplitsInterestAndPrincipal() {
        let debt = Debt(
            id: UUID(),
            name: "Loan",
            remainingAmount: 1_200,
            annualInterestRate: 12,
            durationMonths: 12,
            startDate: date(month: 6, day: 15)
        )

        let summary = PlanningProjectionEngine.project(
            referenceDate: date(month: 6, day: 1),
            projectionHorizon: date(month: 6, day: 30),
            liquidAssets: 2_000,
            investmentPrincipal: 0,
            debts: [debt],
            recurringIncomes: [],
            recurringExpenses: [],
            investments: [],
            netWorthTarget: 0
        )

        let month = summary.months.first
        XCTAssertEqual(month?.liabilityInterest, 12)
        XCTAssertGreaterThan(month?.liabilityPrincipal ?? 0, 0)
        XCTAssertLessThan(month?.liabilityPrincipal ?? 0, month?.liabilityPayments ?? 0)
    }

    func testRecurringExpensesReduceProjectedNetWorth() {
        let expense = RecurringExpense(
            id: UUID(),
            name: "Rent",
            amount: 100,
            dayOfMonth: 10
        )

        let summary = PlanningProjectionEngine.project(
            referenceDate: date(month: 6, day: 1),
            projectionHorizon: date(month: 6, day: 30),
            liquidAssets: 1_000,
            investmentPrincipal: 0,
            debts: [],
            recurringIncomes: [],
            recurringExpenses: [expense],
            investments: [],
            netWorthTarget: 0
        )

        XCTAssertEqual(summary.totalRecurringExpenses, 100)
        XCTAssertEqual(summary.projectedNetWorth, 900)
    }

    func testInvestmentReturnsAddMonthlyCashflowWhileActive() {
        let investment = SBNInvestment(
            id: UUID(),
            name: "Fixed return",
            principal: 1_200,
            annualInterestRate: 12,
            durationMonths: 12,
            startDate: date(month: 6, day: 10)
        )

        let summary = PlanningProjectionEngine.project(
            referenceDate: date(month: 6, day: 1),
            projectionHorizon: date(month: 6, day: 30),
            liquidAssets: 0,
            investmentPrincipal: 1_200,
            debts: [],
            recurringIncomes: [],
            recurringExpenses: [],
            investments: [investment],
            netWorthTarget: 0
        )

        XCTAssertEqual(summary.totalInvestmentReturns, 12)
        XCTAssertEqual(summary.projectedNetWorth, 1_212)
    }

    func testRequiredMonthlySurplusIsZeroWhenTargetIsReached() {
        let summary = PlanningProjectionEngine.project(
            referenceDate: date(month: 6, day: 1),
            projectionHorizon: date(month: 6, day: 30),
            liquidAssets: 1_000,
            investmentPrincipal: 0,
            debts: [],
            recurringIncomes: [],
            recurringExpenses: [],
            investments: [],
            netWorthTarget: 900
        )

        XCTAssertEqual(summary.requiredMonthlySurplus, 0)
    }

    func testRequiredMonthlySurplusIsPositiveWhenTargetIsMissed() {
        let summary = PlanningProjectionEngine.project(
            referenceDate: date(month: 6, day: 1),
            projectionHorizon: date(month: 6, day: 30),
            liquidAssets: 1_000,
            investmentPrincipal: 0,
            debts: [],
            recurringIncomes: [],
            recurringExpenses: [],
            investments: [],
            netWorthTarget: 1_100
        )

        XCTAssertEqual(summary.requiredMonthlySurplus, 100)
    }

    private func date(month: Int, day: Int) -> Date {
        DateComponents(
            calendar: .worthly,
            timeZone: Calendar.worthly.timeZone,
            year: 2026,
            month: month,
            day: day,
            hour: 12
        ).date!
    }
}
