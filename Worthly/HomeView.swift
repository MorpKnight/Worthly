//
//  HomeView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct HomeView: View {
    let store: FinanceStore

    @State private var activeSetupAssetKind: AddAssetKind?

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    private var showsGuidedSetup: Bool {
        !store.isInitialSetupComplete
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                NetWorthCard(
                    netWorth: store.currentNetWorth,
                    changeText: store.netWorthChangeText
                )

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        metricCards
                    }

                    VStack(spacing: 10) {
                        metricCards
                    }
                }

                if showsGuidedSetup {
                    GuidedSetupCard(
                        hasAccount: !store.accounts.isEmpty,
                        hasLiabilityAnswer: !store.debts.isEmpty || store.hasAnsweredLiabilitySetup,
                        hasInvestment: !store.sbnInvestments.isEmpty,
                        onAddAccount: { activeSetupAssetKind = .liquidAccount },
                        onAddLiability: { activeSetupAssetKind = .liability },
                        onConfirmNoLiabilities: { store.confirmNoLiabilities() },
                        onAddInvestment: { activeSetupAssetKind = .sbnInvestment }
                    )
                }

                if !store.checklistActions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Next action")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(store.checklistActions) { action in
                                ChecklistRow(title: action.title, isCompleted: action.isCompleted)
                            }
                        }
                    }
                }

                if !store.recentTransactions.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Transactions")
                            .font(.headline)

                        VStack(spacing: 0) {
                            ForEach(store.recentTransactions.prefix(5)) { transaction in
                                WorthlyTransactionRow(
                                    icon: transaction.displayIcon,
                                    title: transaction.category,
                                    subtitle: transaction.subtitle(
                                        accountName: store.accountName(for: transaction.accountID),
                                        destinationAccountName: store.destinationAccountName(for: transaction)
                                    ),
                                    amount: transaction.displayAmount,
                                    iconTint: transaction.displayTint
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Overview")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorthlyToolbarIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "Add item"
                ) {
                    activeSetupAssetKind = .liquidAccount
                }
            }
        }
        .sheet(item: $activeSetupAssetKind) { kind in
            AddAssetEditorSheet(
                initialKind: kind,
                referenceDate: store.referenceDate,
                onSaveAccount: { store.addAccount($0) },
                onSaveInvestment: { store.addInvestment($0) },
                onSaveDebt: { store.addDebt($0) }
            )
            .presentationDetents([.height(620), .medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
            .presentationBackground(.regularMaterial)
        }
    }

    @ViewBuilder
    private var metricCards: some View {
        MetricCard(
            title: "Cashflow",
            value: IDRFormatting.signedCompact(store.currentMonthCashflow),
            valueColor: store.currentMonthCashflow < 0
                ? WorthlyAccessibleColor.negative
                : WorthlyAccessibleColor.positive
        )

        MetricCard(
            title: "View Planning",
            value: IDRFormatting.compact(store.projectedNetWorth),
            valueColor: .primary
        )
    }
}

private struct NetWorthCard: View {
    let netWorth: Decimal
    let changeText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Net Worth")
                .font(.subheadline)

            WorthlyAmountText(
                text: IDRFormatting.full(netWorth),
                font: .title2.weight(.bold),
                minimumScaleFactor: 0.78
            )

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .firstTextBaseline) {
                    formulaText

                    Spacer()

                    WorthlyAmountText(text: changeText, font: .caption)
                }

                VStack(alignment: .leading, spacing: 4) {
                    formulaText
                    WorthlyAmountText(text: changeText, font: .caption)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Current net worth \(IDRFormatting.full(netWorth)), change \(changeText)")
    }

    private var formulaText: some View {
        Text("Liquid Assets + Investments - Liabilities")
            .font(.caption)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct GuidedSetupCard: View {
    let hasAccount: Bool
    let hasLiabilityAnswer: Bool
    let hasInvestment: Bool
    let onAddAccount: () -> Void
    let onAddLiability: () -> Void
    let onConfirmNoLiabilities: () -> Void
    let onAddInvestment: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Build your money map")
                    .font(.headline)

                Text("Start with where your money is stored, then mark whether you have liabilities.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 8) {
                if !hasAccount {
                    GuidedSetupButton(
                        title: "Add first account",
                        systemImage: "wallet.pass",
                        isPrimary: true,
                        action: onAddAccount
                    )
                }

                if hasAccount && !hasLiabilityAnswer {
                    GuidedSetupButton(
                        title: "Add liabilities",
                        systemImage: "creditcard",
                        isPrimary: true,
                        action: onAddLiability
                    )

                    GuidedSetupButton(
                        title: "I have no liabilities",
                        systemImage: "checkmark.circle",
                        isPrimary: false,
                        action: onConfirmNoLiabilities
                    )
                }

                if hasAccount && !hasInvestment {
                    GuidedSetupButton(
                        title: "Add investment",
                        systemImage: "percent",
                        isPrimary: false,
                        action: onAddInvestment
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Build your money map")
        .accessibilityValue(setupProgress)
    }

    private var setupProgress: String {
        var completed: [String] = []

        if hasAccount {
            completed.append("account added")
        }

        if hasLiabilityAnswer {
            completed.append("liability status answered")
        }

        if hasInvestment {
            completed.append("investment added")
        }

        return completed.isEmpty ? "No setup steps completed" : completed.joined(separator: ", ")
    }
}

private struct GuidedSetupButton: View {
    let title: String
    let systemImage: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        if isPrimary {
            Button(action: action) {
                label
            }
            .buttonStyle(.borderedProminent)
        } else {
            Button(action: action) {
                label
            }
            .buttonStyle(.bordered)
        }
    }

    private var label: some View {
        Label(title, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .frame(maxWidth: .infinity, minHeight: 42)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title)
                .font(.subheadline)

            WorthlyAmountText(
                text: value,
                font: .title2.weight(.bold),
                color: valueColor,
                minimumScaleFactor: 0.8
            )
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 98, alignment: .leading)
        .background(WorthlyCardBackground())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}

private struct ChecklistRow: View {
    let title: String
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isCompleted ? "circle.fill" : "circle")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(.primary)

            Text(title)
                .font(.body)
                .strikethrough(isCompleted, color: .primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(isCompleted ? "\(title), completed" : "\(title), not completed")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
