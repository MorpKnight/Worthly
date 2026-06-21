//
//  WorthlyDateFormatting.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import Foundation

enum WorthlyDateFormatting {
    static func projectionHorizon(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d yyyy"

        return formatter.string(from: date)
    }

    static func historyMonthSummaryTitle(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM"

        return "\(formatter.string(from: date)) summary"
    }

    static func historySectionTitle(for date: Date, referenceDate: Date) -> String {
        let calendar = Calendar(identifier: .gregorian)

        if calendar.isDate(date, inSameDayAs: referenceDate) {
            return "Today"
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: referenceDate),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "Yesterday"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMMM d"

        return formatter.string(from: date)
    }
}
