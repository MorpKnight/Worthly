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
        WorthlySummaryCard(minHeight: 98) {
            VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
                Text("Projected \(WorthlyDateFormatting.projectionHorizon(horizon))")
                    .font(.subheadline)

                WorthlyAmountText(
                    text: IDRFormatting.full(projectedNetWorth),
                    font: .title2.weight(.bold),
                    minimumScaleFactor: 0.78
                )

                Text("Estimate based on recurring salary, investment returns, and liability payments")
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Projected \(WorthlyDateFormatting.projectionHorizon(horizon)), \(IDRFormatting.full(projectedNetWorth))")
    }
}

struct PlanningEmptyStateCard: View {
    var body: some View {
        WorthlySummaryCard(minHeight: 90) {
            VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
                Text("Projection unavailable")
                    .font(.subheadline)

                Text("Add an account to start estimating your money map.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct TargetReadinessCard: View {
    let summary: PlanningProjectionSummary
    let horizon: Date

    var body: some View {
        WorthlySummaryCard(minHeight: 86) {
            VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
                Text(title)
                    .font(.subheadline)

                WorthlyAmountText(
                    text: amountText,
                    font: .title2.weight(.bold),
                    color: amountColor,
                    minimumScaleFactor: 0.78
                )

                Text(helperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(amountText), \(helperText)")
    }

    private var title: String {
        if !summary.hasTarget {
            return "Target status"
        }

        return summary.isOnTrack ? "On track" : "Extra needed per month"
    }

    private var amountText: String {
        if !summary.hasTarget {
            return "Target not set"
        }

        if summary.isOnTrack {
            return IDRFormatting.signedCompact(summary.gapToTarget)
        }

        return "\(IDRFormatting.compact(summary.requiredMonthlySurplus)) / month"
    }

    private var amountColor: Color {
        if !summary.hasTarget {
            return .secondary
        }

        return summary.isOnTrack ? WorthlyAccessibleColor.positive : WorthlyAccessibleColor.negative
    }

    private var helperText: String {
        if !summary.hasTarget {
            return "Set a target to check whether this plan is enough."
        }

        if summary.isOnTrack {
            return "Projected above target by \(WorthlyDateFormatting.projectionHorizon(horizon))."
        }

        return "Additional monthly surplus needed to reach target by \(WorthlyDateFormatting.projectionHorizon(horizon))."
    }
}

struct GapCard: View {
    let gap: Decimal
    let target: Decimal

    private var hasTarget: Bool {
        target > 0
    }

    var body: some View {
        WorthlySummaryCard(minHeight: 70) {
            VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
                Text("Gap to target")
                    .font(.subheadline)

                if hasTarget {
                    WorthlyAmountText(
                        text: IDRFormatting.signedCompact(gap),
                        font: .title2.weight(.bold),
                        color: gap < 0 ? WorthlyAccessibleColor.negative : WorthlyAccessibleColor.positive,
                        minimumScaleFactor: 0.78
                    )
                } else {
                    Text("Set a target to track your gap")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        if hasTarget {
            return "Gap to target, \(IDRFormatting.signedCompact(gap))"
        }

        return "Gap to target, set a target to track your gap"
    }
}

struct PlanningMonthlyBreakdownCard: View {
    let summary: PlanningProjectionSummary

    var body: some View {
        WorthlySummaryCard(minHeight: 172) {
            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                    Text("Monthly plan")
                        .font(.subheadline)

                    Text("Average across \(summary.months.count) projected month\(summary.months.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: WorthlySpacing.xs) {
                    PlanningBreakdownRow(
                        title: "Income",
                        value: IDRFormatting.signedCompact(summary.averageMonthlyIncome),
                        color: WorthlyAccessibleColor.positive
                    )

                    PlanningBreakdownRow(
                        title: "Investment returns",
                        value: IDRFormatting.signedCompact(summary.averageMonthlyInvestmentReturns),
                        color: WorthlyAccessibleColor.positive
                    )

                    PlanningBreakdownRow(
                        title: "Recurring expenses",
                        value: IDRFormatting.signedCompact(-summary.averageMonthlyRecurringExpenses),
                        color: WorthlyAccessibleColor.negative
                    )

                    PlanningBreakdownRow(
                        title: "Liability payments",
                        value: IDRFormatting.signedCompact(-summary.averageMonthlyLiabilityPayments),
                        color: WorthlyAccessibleColor.negative
                    )

                    PlanningBreakdownRow(
                        title: "Liability interest",
                        value: IDRFormatting.signedCompact(-summary.averageMonthlyLiabilityInterest),
                        color: WorthlyAccessibleColor.negative
                    )
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PlanningBreakdownRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: WorthlySpacing.sm) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer(minLength: WorthlySpacing.sm)

                WorthlyAmountText(
                    text: value,
                    font: .caption.weight(.semibold),
                    color: color
                )
            }

            VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                WorthlyAmountText(
                    text: value,
                    font: .caption.weight(.semibold),
                    color: color
                )
            }
        }
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
    let range: ClosedRange<Date>

    var body: some View {
        DatePicker(
            "Projection horizon",
            selection: $selection,
            in: range,
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
