//
//  PlanningEditorModels.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import Foundation

enum PlanningInputFormatting {
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

struct RecurringExpenseDraft: Identifiable {
    let id: UUID
    var name: String
    var amountText: String
    var dayText: String

    init() {
        id = UUID()
        name = ""
        amountText = ""
        dayText = "1"
    }

    init(expense: RecurringExpense) {
        id = expense.id
        name = expense.name
        amountText = PlanningInputFormatting.currency(expense.amount)
        dayText = "\(expense.dayOfMonth)"
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var amount: Decimal? {
        PlanningInputFormatting.decimal(from: amountText)
    }

    private var dayOfMonth: Int? {
        guard let day = PlanningInputFormatting.integer(from: dayText) else {
            return nil
        }

        return min(max(day, 1), 31)
    }

    var isValid: Bool {
        guard let amount, dayOfMonth != nil else {
            return false
        }

        return !trimmedName.isEmpty && amount > 0
    }

    var expense: RecurringExpense? {
        guard let amount, let dayOfMonth, isValid else {
            return nil
        }

        return RecurringExpense(
            id: id,
            name: trimmedName,
            amount: amount,
            dayOfMonth: dayOfMonth
        )
    }
}

extension Debt {
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
