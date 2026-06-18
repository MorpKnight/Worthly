//
//  WorthlyDisclosureRow.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct WorthlyDisclosureRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

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
    let showsChevron: Bool

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
        valueUsesMonospacedDigits: Bool = true,
        showsChevron: Bool = true
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
        self.showsChevron = showsChevron
    }

    var body: some View {
        Group {
            if dynamicTypeSize.isWorthlyAccessibilitySize {
                accessibilityLayout
            } else {
                compactLayout
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, dynamicTypeSize.isWorthlyAccessibilitySize ? WorthlySpacing.xs : 0)
        .frame(minHeight: rowMinHeight)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
                .padding(.leading, separatorLeadingInset)
        }
        .accessibilityElement(children: .combine)
    }

    private var compactLayout: some View {
        HStack(spacing: icon == nil ? WorthlySpacing.sm : WorthlySpacing.md) {
            if icon != nil {
                iconView
            }

            titleBlock

            Spacer(minLength: WorthlySpacing.sm)

            if let value {
                valueView(value)
            }

            if showsChevron {
                chevronView
            }
        }
    }

    private var accessibilityLayout: some View {
        HStack(alignment: .top, spacing: icon == nil ? WorthlySpacing.sm : WorthlySpacing.md) {
            if icon != nil {
                iconView
                    .padding(.top, WorthlySpacing.xxs)
            }

            VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                titleBlock

                if let value {
                    valueView(value)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if showsChevron {
                chevronView
                    .padding(.top, WorthlySpacing.xxs)
            }
        }
    }

    private var iconView: some View {
        Image(systemName: icon ?? "")
            .font(.body.weight(.regular))
            .foregroundStyle(.primary)
            .frame(width: 42)
            .frame(minHeight: 44)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
            Text(title)
                .font(.body)
                .foregroundStyle(titleColor)
                .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 2)
                .minimumScaleFactor(dynamicTypeSize.isWorthlyAccessibilitySize ? 1 : 0.82)

            if let subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 2)
            }
        }
    }

    @ViewBuilder
    private func valueView(_ value: String) -> some View {
        if valueUsesMonospacedDigits {
            WorthlyAmountText(text: value, font: .body, color: valueColor)
        } else {
            Text(value)
                .font(.body)
                .foregroundStyle(valueColor)
                .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 1)
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
        WorthlyDisclosureRow(
            icon: "building.columns",
            title: "Bank Central Asia",
            subtitle: "Savings",
            value: "Rp 990M",
            separatorLeadingInset: 56
        )

        WorthlyDisclosureRow(title: "Monthly salary", value: "Rp 13.5M")

        WorthlyDisclosureRow(
            title: "Reset local data",
            titleColor: WorthlyAccessibleColor.negative,
            rowMinHeight: 52,
            horizontalPadding: 16,
            separatorLeadingInset: 16,
            valueUsesMonospacedDigits: false
        )
    }
    .padding(.horizontal)
}
