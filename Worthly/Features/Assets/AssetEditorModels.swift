//
//  AssetEditorModels.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import Foundation

enum AddAssetKind: String, CaseIterable, Identifiable {
    case liquidAccount
    case sbnInvestment
    case liability

    var id: Self { self }

    var title: String {
        switch self {
        case .liquidAccount:
            "Account"
        case .sbnInvestment:
            "Investment"
        case .liability:
            "Liability"
        }
    }
}

struct AccountDraft {
    let id: UUID
    var name: String
    var type: AccountType
    var balanceText: String
    var createdAt: Date

    init(referenceDate: Date) {
        id = UUID()
        name = ""
        type = .bank
        balanceText = ""
        createdAt = referenceDate
    }

    init(account: Account) {
        id = account.id
        name = account.name
        type = account.type
        balanceText = IDRFormatting.full(account.balance)
        createdAt = account.createdAt
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var balance: Decimal? {
        AssetInputFormatting.decimal(from: balanceText)
    }

    var isValid: Bool {
        guard let balance else {
            return false
        }

        return !trimmedName.isEmpty && balance > 0
    }

    var account: Account? {
        guard let balance, isValid else {
            return nil
        }

        return Account(
            id: id,
            name: trimmedName,
            type: type,
            balance: balance,
            createdAt: createdAt
        )
    }
}

struct InvestmentDraft {
    let id: UUID
    var name: String
    var principalText: String
    var annualInterestRateText: String
    var durationMonthsText: String
    var startDate: Date

    init(referenceDate: Date) {
        id = UUID()
        name = ""
        principalText = ""
        annualInterestRateText = ""
        durationMonthsText = "24"
        startDate = referenceDate
    }

    init(investment: SBNInvestment) {
        id = investment.id
        name = investment.name
        principalText = IDRFormatting.full(investment.principal)
        annualInterestRateText = AssetInputFormatting.decimalText(investment.annualInterestRate)
        durationMonthsText = "\(investment.durationMonths)"
        startDate = investment.startDate
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var principal: Decimal? {
        AssetInputFormatting.decimal(from: principalText)
    }

    private var annualInterestRate: Decimal? {
        AssetInputFormatting.decimal(from: annualInterestRateText)
    }

    private var durationMonths: Int? {
        AssetInputFormatting.integer(from: durationMonthsText)
    }

    var isValid: Bool {
        guard let principal, let annualInterestRate, let durationMonths else {
            return false
        }

        return !trimmedName.isEmpty
            && principal > 0
            && annualInterestRate >= 0
            && durationMonths > 0
    }

    var investment: SBNInvestment? {
        guard let principal, let annualInterestRate, let durationMonths, isValid else {
            return nil
        }

        return SBNInvestment(
            id: id,
            name: trimmedName,
            principal: principal,
            annualInterestRate: annualInterestRate,
            durationMonths: durationMonths,
            startDate: startDate
        )
    }
}

struct DebtDraft {
    let id: UUID
    var name: String
    var remainingAmountText: String
    var annualInterestRateText: String
    var durationMonthsText: String
    var startDate: Date

    init(referenceDate: Date) {
        id = UUID()
        name = ""
        remainingAmountText = ""
        annualInterestRateText = ""
        durationMonthsText = "12"
        startDate = referenceDate
    }

    init(debt: Debt) {
        id = debt.id
        name = debt.name
        remainingAmountText = IDRFormatting.full(debt.remainingAmount)
        annualInterestRateText = AssetInputFormatting.decimalText(debt.annualInterestRate)
        durationMonthsText = "\(debt.durationMonths)"
        startDate = debt.startDate
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var remainingAmount: Decimal? {
        AssetInputFormatting.decimal(from: remainingAmountText)
    }

    private var annualInterestRate: Decimal? {
        AssetInputFormatting.decimal(from: annualInterestRateText)
    }

    private var durationMonths: Int? {
        AssetInputFormatting.integer(from: durationMonthsText)
    }

    var isValid: Bool {
        guard let remainingAmount, let annualInterestRate, let durationMonths else {
            return false
        }

        return !trimmedName.isEmpty
            && remainingAmount > 0
            && annualInterestRate >= 0
            && durationMonths > 0
    }

    var debt: Debt? {
        guard let remainingAmount, let annualInterestRate, let durationMonths, isValid else {
            return nil
        }

        return Debt(
            id: id,
            name: trimmedName,
            remainingAmount: remainingAmount,
            annualInterestRate: annualInterestRate,
            durationMonths: durationMonths,
            startDate: startDate
        )
    }
}

private enum AssetInputFormatting {
    static func decimalText(_ amount: Decimal) -> String {
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

        guard !digits.isEmpty else {
            return nil
        }

        return Int(digits)
    }
}

extension AccountType {
    var editorTitle: String {
        switch self {
        case .bank:
            "Bank"
        case .eWallet:
            "e-wallet"
        case .cash:
            "Cash"
        }
    }
}
