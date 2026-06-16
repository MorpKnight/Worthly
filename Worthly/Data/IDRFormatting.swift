//
//  IDRFormatting.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import Foundation

enum IDRFormatting {
    static func full(_ amount: Decimal) -> String {
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

    static func compact(_ amount: Decimal) -> String {
        let absoluteAmount = abs(amount)
        let absoluteValue = double(from: absoluteAmount)
        let units: [(threshold: Double, suffix: String)] = [
            (1_000_000_000, "B"),
            (1_000_000, "M"),
            (1_000, "K")
        ]

        guard let unit = units.first(where: { absoluteValue >= $0.threshold }) else {
            return full(absoluteAmount)
        }

        let scaled = absoluteValue / unit.threshold

        return "Rp \(compactNumber(scaled))\(unit.suffix)"
    }

    static func signedCompact(_ amount: Decimal) -> String {
        if amount == 0 {
            return compact(amount)
        }

        return "\(amount < 0 ? "-" : "+") \(compact(abs(amount)))"
    }

    static func percent(_ amount: Decimal) -> String {
        let number = double(from: amount)
        let formatted = compactNumber(number)

        return "\(formatted)%"
    }

    private static func abs(_ amount: Decimal) -> Decimal {
        amount < 0 ? -amount : amount
    }

    private static func double(from amount: Decimal) -> Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }

    private static func compactNumber(_ value: Double) -> String {
        let rounded = value.rounded()

        if Swift.abs(value - rounded) < 0.05 {
            return String(format: "%.0f", rounded)
        }

        return String(format: "%.1f", value)
    }
}
