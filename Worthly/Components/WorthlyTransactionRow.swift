//
//  WorthlyTransactionRow.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct WorthlyTransactionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let amount: String
    let iconTint: Color

    private var amountColor: Color {
        if amount.hasPrefix("+") {
            return .green
        }

        if amount.hasPrefix("-") {
            return .red
        }

        return .secondary
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(iconTint)
                .frame(width: 42, height: 54)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }

            Spacer(minLength: 12)

            WorthlyAmountText(text: amount, font: .body, color: amountColor)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .frame(minHeight: 60)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
                .padding(.leading, 56)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 0) {
        WorthlyTransactionRow(
            icon: "square.and.arrow.down",
            title: "Salary",
            subtitle: "Income - BCA",
            amount: "+ Rp 8M",
            iconTint: .green
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
