//
//  FinanceModels.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import Foundation

enum AccountType: String, CaseIterable, Identifiable, Codable {
    case bank
    case eWallet
    case cash

    var id: Self { self }

    var title: String {
        switch self {
        case .bank:
            "Savings"
        case .eWallet:
            "e-wallet"
        case .cash:
            "Cash"
        }
    }
}

enum FinanceTransactionType: String, CaseIterable, Identifiable, Codable {
    case income
    case outcome
    case account

    var id: Self { self }

    var title: String {
        switch self {
        case .income:
            "Income"
        case .outcome:
            "Expense"
        case .account:
            "Account"
        }
    }
}

struct Account: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: AccountType
    var balance: Decimal
    var createdAt: Date
}

struct FinanceTransaction: Identifiable, Codable {
    let id: UUID
    var type: FinanceTransactionType
    var amount: Decimal
    var category: String
    var accountID: UUID
    var destinationAccountID: UUID?
    var date: Date
    var note: String

    var displaySignedAmount: Decimal {
        switch type {
        case .income:
            amount
        case .outcome, .account:
            -amount
        }
    }

    var cashflowAmount: Decimal {
        switch type {
        case .income:
            amount
        case .outcome:
            -amount
        case .account:
            0
        }
    }
}

struct SBNInvestment: Identifiable, Codable {
    let id: UUID
    var name: String
    var principal: Decimal
    var annualInterestRate: Decimal
    var durationMonths: Int
    var startDate: Date

    var estimatedMonthlyCoupon: Decimal {
        principal * (annualInterestRate / 100) / 12
    }

    func maturityDate(using calendar: Calendar = .worthly) -> Date {
        calendar.date(byAdding: .month, value: durationMonths, to: startDate) ?? startDate
    }
}

struct Debt: Identifiable, Codable {
    let id: UUID
    var name: String
    var remainingAmount: Decimal
    var annualInterestRate: Decimal
    var durationMonths: Int
    var startDate: Date

    var estimatedMonthlyInstallment: Decimal {
        let monthCount = max(durationMonths, 1)

        guard annualInterestRate > 0 else {
            return remainingAmount / Decimal(monthCount)
        }

        let principal = NSDecimalNumber(decimal: remainingAmount).doubleValue
        let monthlyRate = NSDecimalNumber(decimal: annualInterestRate).doubleValue / 100 / 12
        let denominator = 1 - pow(1 + monthlyRate, -Double(monthCount))

        guard denominator > 0 else {
            return remainingAmount / Decimal(monthCount)
        }

        return Decimal(principal * monthlyRate / denominator)
    }

    func maturityDate(using calendar: Calendar = .worthly) -> Date {
        calendar.date(byAdding: .month, value: durationMonths, to: startDate) ?? startDate
    }
}

struct RecurringIncome: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Decimal
    var payday: Int
}

struct ChecklistAction: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

struct FinanceTransactionGroup: Identifiable {
    let id: String
    var title: String
    var transactions: [FinanceTransaction]
}

extension Calendar {
    static var worthly: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Jakarta") ?? .current

        return calendar
    }
}
