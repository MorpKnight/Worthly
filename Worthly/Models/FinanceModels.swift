//
//  FinanceModels.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import Foundation

enum AccountType: String, CaseIterable, Identifiable {
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

enum FinanceTransactionType: String, CaseIterable, Identifiable {
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

struct Account: Identifiable {
    let id: UUID
    var name: String
    var type: AccountType
    var balance: Decimal
    var createdAt: Date
}

struct FinanceTransaction: Identifiable {
    let id: UUID
    var type: FinanceTransactionType
    var amount: Decimal
    var category: String
    var accountID: UUID
    var date: Date
    var note: String

    var displaySignedAmount: Decimal {
        switch type {
        case .income, .account:
            amount
        case .outcome:
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

struct SBNInvestment: Identifiable {
    let id: UUID
    var name: String
    var principal: Decimal
    var annualInterestRate: Decimal
    var durationMonths: Int
    var startDate: Date

    var estimatedMonthlyCoupon: Decimal {
        principal * (annualInterestRate / 100) / 12
    }
}

struct Debt: Identifiable {
    let id: UUID
    var name: String
    var remainingAmount: Decimal
    var annualInterestRate: Decimal
    var durationMonths: Int
    var startDate: Date

    var estimatedMonthlyInstallment: Decimal {
        let monthCount = Decimal(max(durationMonths, 1))
        let principalPayment = remainingAmount / monthCount
        let monthlyInterest = remainingAmount * (annualInterestRate / 100) / 12

        return principalPayment + monthlyInterest
    }
}

struct RecurringIncome: Identifiable {
    let id: UUID
    var name: String
    var amount: Decimal
    var payday: Int
}

struct ChecklistAction: Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

struct FinanceTransactionGroup: Identifiable {
    let id: String
    var title: String
    var transactions: [FinanceTransaction]
}
