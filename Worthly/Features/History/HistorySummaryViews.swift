//
//  HistorySummaryViews.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct HistoryEmptyState: View {
    var body: some View {
        WorthlyEmptyStateCard(
            systemImage: "list.bullet.rectangle",
            title: "No transactions yet",
            message: "Income, expenses, and account transfers will appear here."
        )
    }
}

struct HistoryFilterEmptyState: View {
    var body: some View {
        Text("No transactions match this filter.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, minHeight: 80, alignment: .center)
    }
}

struct SearchField: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(alignment: dynamicTypeSize.isWorthlyAccessibilitySize ? .top : .center, spacing: WorthlySpacing.xs) {
            Image(systemName: "magnifyingglass")
                .font(.title3.weight(.medium))
                .foregroundStyle(.secondary)

            Text("Search")
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 1)

            Spacer(minLength: WorthlySpacing.xs)

            Image(systemName: "mic")
                .font(.body.weight(.medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, WorthlySpacing.sm)
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.sm : 0)
        .frame(minHeight: 48)
        .background(Color(.secondarySystemGroupedBackground), in: Capsule())
        .accessibilityLabel("Search transactions")
    }
}

struct JuneSummaryCard: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let total: Decimal
    let count: Int

    var body: some View {
        WorthlySummaryCard(minHeight: 98) {
            ViewThatFits(in: .horizontal) {
                HStack(alignment: .bottom) {
                    amountBlock

                    Spacer()

                    countBlock
                }

                VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                    amountBlock
                    countBlock
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("June summary, \(IDRFormatting.signedCompact(total)), \(count) transactions")
    }

    private var amountColor: Color {
        total < 0 ? WorthlyAccessibleColor.negative : WorthlyAccessibleColor.positive
    }

    private var amountBlock: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.md) {
            Text("June summary")
                .font(.caption)

            WorthlyAmountText(
                text: IDRFormatting.signedCompact(total),
                font: .title3.weight(.bold),
                color: amountColor
            )
        }
    }

    private var countBlock: some View {
        VStack(alignment: dynamicTypeSize.isWorthlyAccessibilitySize ? .leading : .trailing, spacing: WorthlySpacing.xxs) {
            WorthlyAmountText(text: "\(count)x", font: .caption)

            Text("Transactions")
                .font(.caption)
        }
    }
}

struct HistorySection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            WorthlySectionHeader(title: title)

            VStack(spacing: 0) {
                content
            }
        }
    }
}
