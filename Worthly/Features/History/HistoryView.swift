//
//  HistoryView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct HistoryView: View {
    let store: FinanceStore

    @State private var selectedFilter = HistoryFilter.all
    @State private var activeEditor: HistoryTransactionEditor?

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    private var filteredTransactions: [FinanceTransaction] {
        store.transactions(for: selectedFilter.transactionType)
    }

    private var transactionGroups: [FinanceTransactionGroup] {
        store.groupedTransactions(for: filteredTransactions)
    }

    private var referenceMonthSummary: (total: Decimal, count: Int) {
        store.referenceMonthSummary
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                Picker("Transaction filter", selection: $selectedFilter) {
                    ForEach(HistoryFilter.allCases) { filter in
                        Text(filter.title)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                if store.transactions.isEmpty {
                    HistoryEmptyState()
                } else {
                    MonthSummaryCard(
                        title: WorthlyDateFormatting.historyMonthSummaryTitle(for: store.referenceDate),
                        total: referenceMonthSummary.total,
                        count: referenceMonthSummary.count
                    )

                    if transactionGroups.isEmpty {
                        HistoryFilterEmptyState()
                    } else {
                        ForEach(transactionGroups) { group in
                            HistorySection(title: group.title) {
                                ForEach(group.transactions) { transaction in
                                    Button {
                                        activeEditor = .edit(transaction.id)
                                    } label: {
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
                                    .buttonStyle(.plain)
                                }
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
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorthlyToolbarIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "Add transaction"
                ) {
                    activeEditor = .add
                }
            }
        }
        .fullScreenCover(item: $activeEditor) { editor in
            switch editor {
            case .add:
                HistoryTransactionEditorSheet(
                    mode: .add,
                    transaction: nil,
                    accounts: store.accounts,
                    referenceDate: store.referenceDate,
                    onSave: { store.addTransaction($0) }
                )
            case .edit(let transactionID):
                if let transaction = store.transactions.first(where: { $0.id == transactionID }) {
                    HistoryTransactionEditorSheet(
                        mode: .edit,
                        transaction: transaction,
                        accounts: store.accounts,
                        referenceDate: store.referenceDate,
                        onSave: { store.updateTransaction($0) }
                    )
                } else {
                    HistoryMissingTransactionSheet()
                }
            }
        }
    }
}

private enum HistoryTransactionEditor: Identifiable {
    case add
    case edit(UUID)

    var id: String {
        switch self {
        case .add:
            "add"
        case .edit(let transactionID):
            "edit-\(transactionID.uuidString)"
        }
    }
}

private enum HistoryFilter: String, CaseIterable, Identifiable {
    case all
    case income
    case expense
    case account

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            "All"
        case .income:
            "Income"
        case .expense:
            "Expense"
        case .account:
            "Transfer"
        }
    }

    var transactionType: FinanceTransactionType? {
        switch self {
        case .all:
            nil
        case .income:
            .income
        case .expense:
            .outcome
        case .account:
            .account
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
