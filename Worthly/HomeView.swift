//
//  HomeView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct HomeView: View {
    let store: FinanceStore

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                NetWorthCard(
                    netWorth: store.currentNetWorth,
                    changeText: store.netWorthChangeText
                )

                HStack(spacing: 10) {
                    MetricCard(
                        title: "Cashflow",
                        value: IDRFormatting.signedCompact(store.currentMonthCashflow),
                        valueColor: store.currentMonthCashflow < 0 ? .red : .green
                    )

                    MetricCard(
                        title: "View Planning",
                        value: IDRFormatting.compact(store.projectedNetWorth),
                        valueColor: .primary
                    )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Next action")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(store.checklistActions) { action in
                            ChecklistRow(title: action.title, isCompleted: action.isCompleted)
                        }
                    }
                }

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
                    // Static first pass; add flow comes in a later iteration.
                }
            }
        }
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

            HStack(alignment: .firstTextBaseline) {
                Text("Liquid Asset + SBN - Debt")
                    .font(.caption)

                Spacer()

                WorthlyAmountText(text: changeText, font: .caption)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WorthlyCardBackground())
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
