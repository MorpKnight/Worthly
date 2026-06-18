//
//  WorthlyTransactionRow.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct WorthlyTransactionRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let icon: String
    let title: String
    let subtitle: String
    let amount: String
    let iconTint: Color

    private var amountColor: Color {
        if amount.hasPrefix("+") {
            return WorthlyAccessibleColor.positive
        }

        if amount.hasPrefix("-") {
            return WorthlyAccessibleColor.negative
        }

        return .secondary
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isWorthlyAccessibilitySize {
                accessibilityLayout
            } else {
                compactLayout
            }
        }
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
        .frame(minHeight: 60)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
                .padding(.leading, WorthlySpacing.transactionSeparator)
        }
        .accessibilityElement(children: .combine)
    }

    private var compactLayout: some View {
        HStack(spacing: WorthlySpacing.md) {
            iconView

            titleBlock

            Spacer(minLength: WorthlySpacing.sm)

            WorthlyAmountText(text: amount, font: .body, color: amountColor)

            chevronView
        }
    }

    private var accessibilityLayout: some View {
        HStack(alignment: .top, spacing: WorthlySpacing.md) {
            iconView
                .padding(.top, WorthlySpacing.xxs)

            VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                titleBlock

                WorthlyAmountText(text: amount, font: .body.weight(.semibold), color: amountColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            chevronView
                .padding(.top, WorthlySpacing.xxs)
        }
    }

    private var iconView: some View {
        Image(systemName: icon)
            .font(.body.weight(.medium))
            .foregroundStyle(iconTint)
            .frame(width: 42)
            .frame(minHeight: 44)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
            Text(title)
                .font(.body)
                .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 2)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 2)
        }
    }

    private var chevronView: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
    }
}

#Preview {
    VStack(spacing: 0) {
        WorthlyTransactionRow(
            icon: "square.and.arrow.down",
            title: "Salary",
            subtitle: "Income - BCA",
            amount: "+ Rp 8M",
            iconTint: WorthlyAccessibleColor.positive
        )

        WorthlyTransactionRow(
            icon: "fork.knife",
            title: "Restaurant",
            subtitle: "Expense - BCA",
            amount: "- Rp 300K",
            iconTint: .teal
        )
    }
    .padding(.horizontal)
}
