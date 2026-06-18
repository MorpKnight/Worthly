//
//  AssetAllocationChart.swift
//  Worthly
//
//  Created by Codex on 2026/06/18.
//

import SwiftUI

struct AssetCompositionChart: View {
    let liquidAssets: Decimal
    let investmentPrincipal: Decimal

    private var slices: [AssetAllocationSlice] {
        [
            AssetAllocationSlice(
                id: "liquid-account",
                title: "Liquid Account",
                amount: liquidAssets,
                color: AssetChartPalette.liquidAccount
            ),
            AssetAllocationSlice(
                id: "sbn-investment",
                title: "Investments",
                amount: investmentPrincipal,
                color: AssetChartPalette.sbnInvestment
            )
        ]
    }

    private var positiveSlices: [AssetAllocationSlice] {
        slices.filter { $0.amount > 0 }
    }

    private var totalAmount: Decimal {
        positiveSlices.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WorthlySpacing.md) {
            VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                Text("Asset Allocation")
                    .font(.headline)

                Text("Liquid accounts + investments")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .center, spacing: WorthlySpacing.lg) {
                    AssetDonutChart(slices: positiveSlices)
                        .frame(width: 164, height: 164)

                    allocationLegend
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: WorthlySpacing.sm) {
                    AssetDonutChart(slices: positiveSlices)
                        .frame(width: 216, height: 216)
                        .frame(maxWidth: .infinity)

                    allocationLegend
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var allocationLegend: some View {
        VStack(spacing: WorthlySpacing.xs) {
            ForEach(positiveSlices) { slice in
                AllocationLegendRow(
                    slice: slice,
                    percentage: percentageText(for: slice)
                )
            }
        }
    }

    private var accessibilitySummary: String {
        guard totalAmount > 0 else {
            return "Asset allocation chart, no assets"
        }

        let summary = positiveSlices
            .map { "\($0.title) \(percentageText(for: $0))" }
            .joined(separator: ", ")

        return "Asset allocation chart, \(summary)"
    }

    private func percentageText(for slice: AssetAllocationSlice) -> String {
        guard totalAmount > 0 else {
            return "0%"
        }

        let sliceValue = NSDecimalNumber(decimal: slice.amount).doubleValue
        let totalValue = NSDecimalNumber(decimal: totalAmount).doubleValue
        let percentage = sliceValue / totalValue * 100

        if percentage > 0 && percentage < 1 {
            return "<1%"
        }

        if abs(percentage.rounded() - percentage) < 0.05 {
            return "\(Int(percentage.rounded()))%"
        }

        return String(format: "%.1f%%", percentage)
    }
}

private struct AssetDonutChart: View {
    let slices: [AssetAllocationSlice]

    private var totalValue: Double {
        slices.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        ZStack {
            Canvas { context, size in
                let lineWidth = min(size.width, size.height) * 0.22
                let radius = min(size.width, size.height) / 2 - lineWidth / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                var startAngle = -90.0

                var basePath = Path()
                basePath.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360),
                    clockwise: false
                )

                context.stroke(
                    basePath,
                    with: .color(Color(.quaternarySystemFill)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )

                guard totalValue > 0 else {
                    return
                }

                for slice in slices {
                    let endAngle = startAngle + 360 * (slice.value / totalValue)
                    var path = Path()

                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle),
                        clockwise: false
                    )

                    context.stroke(
                        path,
                        with: .color(slice.color),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                    )

                    startAngle = endAngle
                }
            }

            VStack(spacing: WorthlySpacing.xxs) {
                Text("Assets")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(totalValue > 0 ? "100%" : "0%")
                    .font(.title3.weight(.bold))
                    .monospacedDigit()
            }
        }
        .accessibilityLabel("Asset allocation donut chart")
    }
}

private struct AllocationLegendRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let slice: AssetAllocationSlice
    let percentage: String

    var body: some View {
        Group {
            if dynamicTypeSize.isWorthlyAccessibilitySize {
                VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                    HStack(spacing: WorthlySpacing.sm) {
                        marker
                        titleText
                    }

                    percentageText

                    WorthlyAmountText(
                        text: IDRFormatting.compact(slice.amount),
                        font: .subheadline,
                        color: .secondary
                    )
                }
            } else {
                HStack(spacing: WorthlySpacing.sm) {
                    marker

                    VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                        titleText
                        percentageText
                    }

                    Spacer(minLength: WorthlySpacing.sm)

                    WorthlyAmountText(
                        text: IDRFormatting.compact(slice.amount),
                        font: .subheadline,
                        color: .secondary
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    private var marker: some View {
        Circle()
            .fill(slice.color)
            .frame(width: WorthlySpacing.md, height: WorthlySpacing.md)
    }

    private var titleText: some View {
        Text(slice.title)
            .font(.subheadline.weight(.semibold))
            .lineLimit(dynamicTypeSize.isWorthlyAccessibilitySize ? nil : 2)
    }

    private var percentageText: some View {
        Text(percentage)
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()
            .lineLimit(1)
    }
}

private struct AssetAllocationSlice: Identifiable {
    let id: String
    let title: String
    let amount: Decimal
    let color: Color

    var value: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

private enum AssetChartPalette {
    static let liquidAccount = WorthlyAccessibleColor.liquidAsset
    static let sbnInvestment = WorthlyAccessibleColor.investment
}
