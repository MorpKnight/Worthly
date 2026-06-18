//
//  WorthlyLayoutComponents.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct WorthlySummaryCard<Content: View>: View {
    let padding: CGFloat
    let minHeight: CGFloat?
    let content: Content

    init(
        padding: CGFloat = WorthlySpacing.sm,
        minHeight: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.minHeight = minHeight
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
            .background(WorthlyCardBackground())
    }
}

struct WorthlySectionHeader: View {
    let title: String
    let amount: String?

    init(title: String, amount: String? = nil) {
        self.title = title
        self.amount = amount
    }

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                titleText

                Spacer()

                if let amount {
                    WorthlyAmountText(text: amount, font: .body, color: .secondary)
                }
            }

            VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                titleText

                if let amount {
                    WorthlyAmountText(text: amount, font: .body, color: .secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var titleText: some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

struct WorthlyEmptyStateCard: View {
    let systemImage: String
    let title: String
    let message: String
    let buttonTitle: String?
    let buttonSystemImage: String?
    let action: (() -> Void)?

    init(
        systemImage: String,
        title: String,
        message: String,
        buttonTitle: String? = nil,
        buttonSystemImage: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.buttonSystemImage = buttonSystemImage
        self.action = action
    }

    var body: some View {
        WorthlySummaryCard(padding: WorthlySpacing.md) {
            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(WorthlyAccessibleColor.accent)

                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let action, let buttonTitle {
                    Button(action: action) {
                        Label(buttonTitle, systemImage: buttonSystemImage ?? "plus")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    VStack(spacing: WorthlySpacing.md) {
        WorthlySummaryCard {
            Text("Summary")
                .font(.headline)
        }

        WorthlySectionHeader(title: "Liquid Account", amount: "Rp 999M")

        WorthlyEmptyStateCard(
            systemImage: "wallet.pass",
            title: "Add your first account",
            message: "Start with one bank, e-wallet, or cash account.",
            buttonTitle: "Add first account"
        ) {}
    }
    .padding()
}
