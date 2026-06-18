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
        VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
            Text("Total Assets")
                .font(.subheadline)

            WorthlyAmountText(
                text: IDRFormatting.full(totalAsset),
                font: .title2.weight(.bold),
                minimumScaleFactor: 0.78
            )
        }
        .padding(WorthlySpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total assets \(IDRFormatting.full(totalAsset))")
    }
}

struct AssetEmptyState: View {
    let onAddAccount: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
            Image(systemName: "wallet.pass")
                .font(.title2.weight(.semibold))
                .foregroundStyle(WorthlyAccessibleColor.accent)

            Text("Add your first account")
                .font(.headline)

            Text("Start with one bank, e-wallet, or cash account.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: onAddAccount) {
                Label("Add first account", systemImage: "plus")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(WorthlySpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

struct AssetSectionHeader: View {
    let title: String
    let amount: String

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)

            Spacer()

            WorthlyAmountText(text: amount, font: .body, color: .secondary)
        }
    }
}
