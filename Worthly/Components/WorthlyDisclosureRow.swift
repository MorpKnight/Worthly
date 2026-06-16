//
//  WorthlyDisclosureRow.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct WorthlyDisclosureRow: View {
    let icon: String?
    let title: String
    let subtitle: String?
    let value: String?
    let titleColor: Color
    let valueColor: Color
    let rowMinHeight: CGFloat
    let horizontalPadding: CGFloat
    let separatorLeadingInset: CGFloat
    let valueUsesMonospacedDigits: Bool

    init(
        icon: String? = nil,
        title: String,
        subtitle: String? = nil,
        value: String? = nil,
        titleColor: Color = .primary,
        valueColor: Color = .secondary,
        rowMinHeight: CGFloat = 60,
        horizontalPadding: CGFloat = 0,
        separatorLeadingInset: CGFloat = 0,
        valueUsesMonospacedDigits: Bool = true
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.titleColor = titleColor
        self.valueColor = valueColor
        self.rowMinHeight = rowMinHeight
        self.horizontalPadding = horizontalPadding
        self.separatorLeadingInset = separatorLeadingInset
        self.valueUsesMonospacedDigits = valueUsesMonospacedDigits
    }

    var body: some View {
        HStack(spacing: icon == nil ? 12 : 14) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(.primary)
                    .frame(width: 42, height: 58)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
            }

            Spacer(minLength: 12)

            if let value {
                if valueUsesMonospacedDigits {
                    WorthlyAmountText(text: value, font: .body, color: valueColor)
                } else {
                    Text(value)
                        .font(.body)
                        .foregroundStyle(valueColor)
                        .lineLimit(1)
                }
            }

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, horizontalPadding)
        .frame(minHeight: rowMinHeight)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
                .padding(.leading, separatorLeadingInset)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack(spacing: 0) {
        WorthlyDisclosureRow(
            icon: "building.columns",
            title: "Bank Central Asia",
            subtitle: "Savings",
            value: "Rp 990M",
            separatorLeadingInset: 56
        )

        WorthlyDisclosureRow(title: "Monthly salary", value: "Rp 13.5M")

        WorthlyDisclosureRow(
            title: "Reset demo data",
            titleColor: .red,
            rowMinHeight: 52,
            horizontalPadding: 16,
            separatorLeadingInset: 16,
            valueUsesMonospacedDigits: false
        )
    }
    .padding(.horizontal)
}
