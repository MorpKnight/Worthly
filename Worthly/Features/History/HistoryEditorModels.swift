//
//  HistoryEditorModels.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import Foundation

enum HistoryEditorMode {
    case add
    case edit

    var title: String {
        switch self {
        case .add:
            "Add Transaction"
        case .edit:
            "Edit Transaction"
        }
    }
}

enum HistoryEditorTransactionType: String, CaseIterable, Identifiable {
    case income
    case outcome
    case account

    var id: Self { self }

    var title: String {
        switch self {
        case .income:
            "Income"
        case .outcome:
            "Outcome"
        case .account:
            "Account"
        }
    }

    var transactionType: FinanceTransactionType {
        switch self {
        case .income:
            .income
        case .outcome:
            .outcome
        case .account:
            .account
        }
    }

    var categories: [String] {
        switch self {
        case .income:
            ["Salary", "Investment return", "Freelance", "Cashback", "Gift", "Side project"]
        case .outcome:
            ["Food", "Groceries", "Debt installment", "Restaurant", "Transport", "Travel", "Phone", "Shopping", "Rent", "Health", "Education", "Coffee"]
        case .account:
            ["Transfer", "Top up", "Savings sweep"]
        }
    }

    var defaultCategory: String {
        categories[0]
    }

    init(transactionType: FinanceTransactionType) {
        switch transactionType {
        case .income:
            self = .income
        case .outcome:
            self = .outcome
        case .account:
            self = .account
        }
    }
}

enum HistoryInputFormatting {
    static func currency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0

        let number = NSDecimalNumber(decimal: amount)
        let value = formatter.string(from: number) ?? number.stringValue

        return "Rp \(value)"
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
}

extension Account {
    var shortDisplayName: String {
        switch name {
        case "Bank Central Asia":
            "BCA"
        case "Bank Mandiri":
            "Mandiri"
        case "Bank Jago":
            "Jago"
        case "BNI Emergency":
            "BNI"
        case "Cash on hand":
            "Cash"
        default:
            name
        }
    }
}
