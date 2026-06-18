//
//  AssetSummaryViews.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct TotalAssetCard: View {
    let totalAsset: Decimal

    var body: some View {
        WorthlySummaryCard {
            VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
                Text("Total Assets")
                    .font(.subheadline)

                WorthlyAmountText(
                    text: IDRFormatting.full(totalAsset),
                    font: .title2.weight(.bold),
                    minimumScaleFactor: 0.78
                )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total assets \(IDRFormatting.full(totalAsset))")
    }
}

struct AssetEmptyState: View {
    let onAddAccount: () -> Void

    var body: some View {
        WorthlyEmptyStateCard(
            systemImage: "wallet.pass",
            title: "Add your first account",
            message: "Start with one bank, e-wallet, or cash account.",
            buttonTitle: "Add first account",
            buttonSystemImage: "plus",
            action: onAddAccount
        )
    }
}

struct AssetSectionHeader: View {
    let title: String
    let amount: String

    var body: some View {
        WorthlySectionHeader(title: title, amount: amount)
    }
}
