//
//  AssetView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct AssetView: View {
    let data: SampleFinanceData

    init(data: SampleFinanceData = .current) {
        self.data = data
    }

    private var pieSlices: [PieSlice] {
        let accountSlices = data.accounts.enumerated().map { index, account in
            PieSlice(
                id: "account-\(account.id.uuidString)",
                title: account.chartTitle,
                amount: account.balance,
                color: AssetChartPalette.color(at: index)
            )
        }

        let investmentSlices = data.sbnInvestments.enumerated().map { index, investment in
            PieSlice(
                id: "sbn-\(investment.id.uuidString)",
                title: investment.name,
                amount: investment.principal,
                color: AssetChartPalette.color(at: data.accounts.count + index)
            )
        }

        return accountSlices + investmentSlices
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                TotalAssetCard(totalAsset: data.totalAssets)

                AssetCompositionChart(slices: pieSlices)
                    .padding(.top, 2)

                AssetSectionHeader(
                    title: "Liquid Account",
                    amount: IDRFormatting.compact(data.liquidAssets)
                )

                VStack(spacing: 0) {
                    ForEach(data.accounts) { account in
                        WorthlyDisclosureRow(
                            icon: account.type.systemImage,
                            title: account.name,
                            subtitle: account.type.title,
                            value: IDRFormatting.compact(account.balance),
                            separatorLeadingInset: 56
                        )
                    }
                }

                AssetSectionHeader(
                    title: "SBN Investment",
                    amount: IDRFormatting.compact(data.investmentPrincipal)
                )

                VStack(spacing: 0) {
                    ForEach(data.sbnInvestments) { investment in
                        WorthlyDisclosureRow(
                            icon: "percent",
                            title: investment.name,
                            subtitle: "\(IDRFormatting.percent(investment.annualInterestRate)) p.a.",
                            value: IDRFormatting.compact(investment.principal),
                            separatorLeadingInset: 56
                        )
                    }
                }

                AssetSectionHeader(
                    title: "Debt",
                    amount: IDRFormatting.compact(data.totalDebt)
                )

                VStack(spacing: 0) {
                    ForEach(data.debts) { debt in
                        WorthlyDisclosureRow(
                            icon: debt.name.lowercased().contains("kpr") ? "house" : "creditcard",
                            title: debt.name,
                            subtitle: "\(debt.durationMonths) months left",
                            value: IDRFormatting.compact(debt.remainingAmount),
                            separatorLeadingInset: 56
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Assets")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    WorthlyToolbarIconButton(
                        systemImage: "plus",
                        accessibilityLabel: "Add asset",
                        size: 32,
                        showsCircleBackground: false
                    ) {
                        // Static first pass; add asset flow comes later.
                    }

                    WorthlyToolbarIconButton(
                        systemImage: "wallet.pass",
                        accessibilityLabel: "Open wallet",
                        size: 32,
                        showsCircleBackground: false
                    ) {
                        // Static first pass; account detail flow comes later.
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}

private struct TotalAssetCard: View {
    let totalAsset: Decimal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total Asset")
                .font(.subheadline)

            WorthlyAmountText(
                text: IDRFormatting.full(totalAsset),
                font: .title2.weight(.bold),
                minimumScaleFactor: 0.78
            )
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
    }
}

private struct AssetCompositionChart: View {
    let slices: [PieSlice]

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var positiveSlices: [PieSlice] {
        slices.filter { $0.amount > 0 }
    }

    private var totalAmount: Decimal {
        positiveSlices.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        VStack(spacing: 14) {
            AssetPieChart(slices: positiveSlices)
                .frame(width: 250, height: 250)
                .frame(maxWidth: .infinity)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
                ForEach(positiveSlices) { slice in
                    PieLegendItem(
                        slice: slice,
                        percentage: percentageText(for: slice)
                    )
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        guard totalAmount > 0 else {
            return "Asset composition chart, no assets"
        }

        let summary = positiveSlices
            .map { "\($0.title) \(percentageText(for: $0))" }
            .joined(separator: ", ")

        return "Asset composition chart, \(summary)"
    }

    private func percentageText(for slice: PieSlice) -> String {
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

private struct AssetPieChart: View {
    let slices: [PieSlice]

    var body: some View {
        Canvas { context, size in
            let total = slices.reduce(0) { $0 + $1.value }
            let diameter = min(size.width, size.height)
            let radius = min(size.width, size.height) / 2
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            var startAngle = -90.0

            guard total > 0 else {
                let rect = CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: diameter,
                    height: diameter
                )
                let emptyPath = Path(ellipseIn: rect)

                context.stroke(
                    emptyPath,
                    with: .color(Color(.separator)),
                    lineWidth: 1
                )

                return
            }

            for slice in slices {
                let endAngle = startAngle + 360 * (slice.value / total)
                var path = Path()

                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: Angle(degrees: startAngle),
                    endAngle: Angle(degrees: endAngle),
                    clockwise: false
                )
                path.closeSubpath()

                context.fill(path, with: .color(slice.color))
                context.stroke(
                    path,
                    with: .color(Color(.systemBackground)),
                    lineWidth: 2
                )
                startAngle = endAngle
            }
        }
        .clipShape(Circle())
        .accessibilityLabel("Asset composition chart")
    }
}

private struct PieLegendItem: View {
    let slice: PieSlice
    let percentage: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(slice.color)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 2) {
                Text(slice.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text(IDRFormatting.compact(slice.amount))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                        .lineLimit(1)

                    Text("(\(percentage))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}

private struct PieSlice: Identifiable {
    let id: String
    let title: String
    let amount: Decimal
    let color: Color

    var value: Double {
        NSDecimalNumber(decimal: amount).doubleValue
    }
}

private enum AssetChartPalette {
    // Each light color is chosen to clear the WCAG/HIG contrast equation
    // (L1 + 0.05) / (L2 + 0.05) >= 3:1 against white system backgrounds.
    // Each dark color is paired to clear the same target against black system backgrounds.
    private static let colors: [Color] = [
        adaptiveColor(
            light: ChartRGB(red: 0, green: 87, blue: 217),
            dark: ChartRGB(red: 121, green: 167, blue: 255)
        ),
        adaptiveColor(
            light: ChartRGB(red: 138, green: 90, blue: 0),
            dark: ChartRGB(red: 255, green: 209, blue: 102)
        ),
        adaptiveColor(
            light: ChartRGB(red: 160, green: 24, blue: 108),
            dark: ChartRGB(red: 255, green: 138, blue: 201)
        ),
        adaptiveColor(
            light: ChartRGB(red: 0, green: 122, blue: 120),
            dark: ChartRGB(red: 72, green: 214, blue: 210)
        ),
        adaptiveColor(
            light: ChartRGB(red: 109, green: 59, blue: 170),
            dark: ChartRGB(red: 198, green: 165, blue: 255)
        ),
        adaptiveColor(
            light: ChartRGB(red: 154, green: 52, blue: 18),
            dark: ChartRGB(red: 255, green: 176, blue: 136)
        ),
        adaptiveColor(
            light: ChartRGB(red: 39, green: 92, blue: 0),
            dark: ChartRGB(red: 155, green: 230, blue: 109)
        ),
        adaptiveColor(
            light: ChartRGB(red: 122, green: 31, blue: 31),
            dark: ChartRGB(red: 255, green: 154, blue: 154)
        ),
        adaptiveColor(
            light: ChartRGB(red: 0, green: 78, blue: 100),
            dark: ChartRGB(red: 141, green: 231, blue: 255)
        ),
        adaptiveColor(
            light: ChartRGB(red: 107, green: 78, blue: 0),
            dark: ChartRGB(red: 247, green: 215, blue: 116)
        ),
        adaptiveColor(
            light: ChartRGB(red: 47, green: 93, blue: 140),
            dark: ChartRGB(red: 167, green: 207, blue: 255)
        ),
        adaptiveColor(
            light: ChartRGB(red: 140, green: 45, blue: 87),
            dark: ChartRGB(red: 255, green: 159, blue: 194)
        ),
        adaptiveColor(
            light: ChartRGB(red: 40, green: 97, blue: 90),
            dark: ChartRGB(red: 141, green: 222, blue: 210)
        ),
        adaptiveColor(
            light: ChartRGB(red: 92, green: 75, blue: 0),
            dark: ChartRGB(red: 230, green: 213, blue: 138)
        )
    ]

    static func color(at index: Int) -> Color {
        colors[index % colors.count]
    }

    private static func adaptiveColor(light: ChartRGB, dark: ChartRGB) -> Color {
        Color(
            uiColor: UIColor { traitCollection in
                let rgb = traitCollection.userInterfaceStyle == .dark ? dark : light

                return UIColor(
                    red: rgb.red,
                    green: rgb.green,
                    blue: rgb.blue,
                    alpha: 1
                )
            }
        )
    }
}

private struct ChartRGB {
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat

    init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.red = red / 255
        self.green = green / 255
        self.blue = blue / 255
    }
}

private struct AssetSectionHeader: View {
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

private extension Account {
    var chartTitle: String {
        switch name {
        case "Bank Central Asia":
            "BCA"
        case "Bank Mandiri":
            "Mandiri"
        case "Bank Jago":
            "Jago"
        case "BNI Emergency":
            "BNI"
        case "Cash on hand":
            "Cash"
        default:
            name
        }
    }
}

#Preview {
    NavigationStack {
        AssetView()
    }
}
