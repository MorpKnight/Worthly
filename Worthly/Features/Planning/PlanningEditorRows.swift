//
//  PlanningEditorRows.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct PlanningTextFieldRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .font(.body.weight(.semibold))
            .monospacedDigit()
            .keyboardType(.decimalPad)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? 1...2 : 1...1)
            .minimumScaleFactor(dynamicTypeSize.isWorthlyAccessibilitySize ? 1 : 0.78)
            .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
            .frame(minHeight: 54, alignment: .leading)
            .overlay(alignment: .bottom) {
                PlanningSeparator()
            }
    }
}

struct PlanningLabeledTextFieldRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            Text(title)
                .font(.body)

            PlanningTextFieldRow(placeholder: placeholder, text: $text)
        }
        .padding(.bottom, WorthlySpacing.sm)
    }
}

struct PlanningMonthYearFieldRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    @Binding var date: Date

    private let years = Array(2020...2032)
    private let months = Array(1...12)

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            Text(title)
                .font(.body)

            Menu {
                ForEach(years, id: \.self) { year in
                    Menu("\(year)") {
                        ForEach(months, id: \.self) { month in
                            Button(PlanningInputFormatting.monthName(month)) {
                                date = PlanningInputFormatting.date(year: year, month: month)
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(PlanningInputFormatting.monthYear(date))
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 1)

                    Spacer()

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
                .frame(minHeight: 54)
                .overlay(alignment: .bottom) {
                    PlanningSeparator()
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, WorthlySpacing.sm)
    }
}

struct PlanningSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color(.separator))
            .frame(height: 0.5)
    }
}
