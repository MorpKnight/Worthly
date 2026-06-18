//
//  PlanningSummaryViews.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct ProjectionCard: View {
    let horizon: Date
    let projectedNetWorth: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            Text("Projected \(WorthlyDateFormatting.projectionHorizon(horizon))")
                .font(.subheadline)

            WorthlyAmountText(
                text: IDRFormatting.full(projectedNetWorth),
                font: .title2.weight(.bold),
                minimumScaleFactor: 0.78
            )

            Text("Estimate based on recurring salary, investment returns, and debt installments")
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthlySpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
        .background(WorthlyCardBackground())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Projected \(WorthlyDateFormatting.projectionHorizon(horizon)), \(IDRFormatting.full(projectedNetWorth))")
    }
}

struct PlanningEmptyStateCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            Text("Projection unavailable")
                .font(.subheadline)

            Text("Add an account to start estimating your money map.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(WorthlySpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

struct GapCard: View {
    let gap: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            Text("Gap to target")
                .font(.subheadline)

            WorthlyAmountText(
                text: IDRFormatting.signedCompact(gap),
                font: .title2.weight(.bold),
                color: gap < 0 ? WorthlyAccessibleColor.negative : WorthlyAccessibleColor.positive,
                minimumScaleFactor: 0.78
            )
        }
        .padding(WorthlySpacing.sm)
        .frame(maxWidth: .infinity, minHeight: 70, alignment: .leading)
        .background(WorthlyCardBackground())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Gap to target, \(IDRFormatting.signedCompact(gap))")
    }
}

struct ProjectionHorizonDisclosureRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let value: String
    let isExpanded: Bool

    var body: some View {
        Group {
            if dynamicTypeSize.isWorthlyAccessibilitySize {
                HStack(alignment: .top, spacing: WorthlySpacing.sm) {
                    VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                        Text("Projection horizon")
                            .font(.body)
                            .foregroundStyle(.primary)

                        Text(value)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: WorthlySpacing.sm)

                    chevron
                        .padding(.top, WorthlySpacing.xxs)
                }
            } else {
                HStack(spacing: WorthlySpacing.sm) {
                    Text("Projection horizon")
                        .font(.body)
                        .foregroundStyle(.primary)

                    Spacer(minLength: WorthlySpacing.sm)

                    Text(value)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    chevron
                }
            }
        }
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
        .frame(minHeight: 60)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Projection horizon, \(value)")
        .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
    }

    private var chevron: some View {
        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(width: 16)
    }
}

struct ProjectionHorizonCalendar: View {
    @Binding var selection: Date

    var body: some View {
        DatePicker(
            "Projection horizon",
            selection: $selection,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .padding(.horizontal, WorthlySpacing.sm)
        .padding(.vertical, WorthlySpacing.xs)
        .background(WorthlyCardBackground(cornerRadius: WorthlySpacing.sm))
        .accessibilityLabel("Projection horizon calendar")
    }
}
