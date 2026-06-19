//
//  HomeView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct HomeView: View {
    let store: FinanceStore

    @State private var activeAddRoute: OverviewAddRoute?

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    private var showsGuidedSetup: Bool {
        !store.isInitialSetupComplete
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                NetWorthCard(
                    netWorth: store.currentNetWorth,
                    changeText: store.netWorthChangeText
                )

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: WorthlySpacing.sm) {
                        metricCards
                    }

                    VStack(spacing: WorthlySpacing.sm) {
                        metricCards
                    }
                }

                if showsGuidedSetup {
                    GuidedSetupCard(
                        hasAccount: !store.accounts.isEmpty,
                        hasLiabilityAnswer: !store.debts.isEmpty || store.hasAnsweredLiabilitySetup,
                        hasInvestment: !store.sbnInvestments.isEmpty,
                        onAddAccount: { activeAddRoute = .account },
                        onAddLiability: { activeAddRoute = .liability },
                        onConfirmNoLiabilities: { store.confirmNoLiabilities() },
                        onAddInvestment: { activeAddRoute = .investment }
                    )
                }

                if !store.checklistActions.isEmpty {
                    VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                        Text("Next action")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                            ForEach(store.checklistActions) { action in
                                ChecklistRow(title: action.title, isCompleted: action.isCompleted)
                            }
                        }
                    }
                }

                if !store.recentTransactions.isEmpty {
                    VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
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
            .padding(.horizontal, WorthlySpacing.screenHorizontal)
            .padding(.top, WorthlySpacing.xs)
            .padding(.bottom, WorthlySpacing.pageBottom)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Overview")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        activeAddRoute = .account
                    } label: {
                        Label("Account", systemImage: "wallet.pass")
                    }

                    Button {
                        activeAddRoute = .transaction
                    } label: {
                        Label("Transaction", systemImage: "list.bullet.rectangle")
                    }

                    Button {
                        activeAddRoute = .liability
                    } label: {
                        Label("Liability", systemImage: "creditcard")
                    }
                } label: {
                    WorthlyToolbarIconLabel(systemImage: "plus")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary)
                .accessibilityLabel("Add")
            }
        }
        .fullScreenCover(item: $activeAddRoute) { route in
            editorView(for: route)
        }
    }

    @ViewBuilder
    private func editorView(for route: OverviewAddRoute) -> some View {
        switch route {
        case .account:
            AddAssetEditorSheet(
                title: "Add Account",
                initialKind: .liquidAccount,
                allowedKinds: [.liquidAccount],
                referenceDate: store.referenceDate,
                onSaveAccount: { store.addAccount($0) },
                onSaveInvestment: { _ in },
                onSaveDebt: { _ in }
            )
        case .transaction:
            HistoryTransactionEditorSheet(
                mode: .add,
                transaction: nil,
                accounts: store.accounts,
                referenceDate: store.referenceDate,
                onSave: { store.addTransaction($0) }
            )
        case .liability:
            AddAssetEditorSheet(
                title: "Add Liability",
                initialKind: .liability,
                allowedKinds: [.liability],
                referenceDate: store.referenceDate,
                onSaveAccount: { _ in },
                onSaveInvestment: { _ in },
                onSaveDebt: { store.addDebt($0) }
            )
        case .investment:
            AddAssetEditorSheet(
                title: "Add Investment",
                initialKind: .sbnInvestment,
                allowedKinds: [.sbnInvestment],
                referenceDate: store.referenceDate,
                onSaveAccount: { _ in },
                onSaveInvestment: { store.addInvestment($0) },
                onSaveDebt: { _ in }
            )
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

private enum OverviewAddRoute: String, Identifiable {
    case account
    case transaction
    case liability
    case investment

    var id: String { rawValue }
}

private struct NetWorthCard: View {
    let netWorth: Decimal
    let changeText: String

    var body: some View {
        WorthlySummaryCard {
            VStack(alignment: .leading, spacing: WorthlySpacing.xs) {
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

                    VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                        formulaText
                        WorthlyAmountText(text: changeText, font: .caption)
                    }
                }
            }
        }
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
        WorthlySummaryCard(padding: WorthlySpacing.md) {
            VStack(alignment: .leading, spacing: WorthlySpacing.md) {
                VStack(alignment: .leading, spacing: WorthlySpacing.xxs) {
                    Text("Build your money map")
                        .font(.headline)

                    Text("Start with where your money is stored, then mark whether you have liabilities.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: WorthlySpacing.xs) {
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
        }
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
            .frame(maxWidth: .infinity, minHeight: 44)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let valueColor: Color

    var body: some View {
        WorthlySummaryCard(minHeight: 98) {
            VStack(alignment: .leading, spacing: WorthlySpacing.lg) {
                Text(title)
                    .font(.subheadline)

                WorthlyAmountText(
                    text: value,
                    font: .title2.weight(.bold),
                    color: valueColor,
                    minimumScaleFactor: 0.8
                )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title), \(value)")
    }
}

private struct ChecklistRow: View {
    let title: String
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: WorthlySpacing.sm) {
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
