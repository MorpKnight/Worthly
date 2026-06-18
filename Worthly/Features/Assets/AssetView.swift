//
//  AssetView.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import SwiftUI

struct AssetView: View {
    let store: FinanceStore

    @State private var activeEditor: AssetEditor?

    init(store: FinanceStore = FinanceStore()) {
        self.store = store
    }

    private var liquidAssets: Decimal {
        store.liquidAssets
    }

    private var investmentPrincipal: Decimal {
        store.investmentPrincipal
    }

    private var totalAssets: Decimal {
        store.totalAssets
    }

    private var totalDebt: Decimal {
        store.totalDebt
    }

    private var hasAssetAllocation: Bool {
        liquidAssets > 0 || investmentPrincipal > 0
    }

    private var sortedAccounts: [Account] {
        store.accounts.sorted { $0.balance > $1.balance }
    }

    private var sortedSbnInvestments: [SBNInvestment] {
        store.sbnInvestments.sorted { $0.principal > $1.principal }
    }

    private var sortedDebts: [Debt] {
        store.debts.sorted { $0.remainingAmount > $1.remainingAmount }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: WorthlySpacing.sm) {
                TotalAssetCard(totalAsset: totalAssets)

                if hasAssetAllocation {
                    AssetCompositionChart(
                        liquidAssets: liquidAssets,
                        investmentPrincipal: investmentPrincipal
                    )
                    .padding(.top, WorthlySpacing.xxs)
                }

                if sortedAccounts.isEmpty {
                    AssetEmptyState {
                        activeEditor = .add(.liquidAccount)
                    }
                } else {
                    AssetSectionHeader(
                        title: "Liquid Account",
                        amount: IDRFormatting.compact(liquidAssets)
                    )

                    VStack(spacing: 0) {
                        ForEach(sortedAccounts) { account in
                            Button {
                                activeEditor = .editAccount(account.id)
                            } label: {
                                WorthlyDisclosureRow(
                                    icon: account.type.systemImage,
                                    title: account.name,
                                    subtitle: account.type.title,
                                    value: IDRFormatting.compact(account.balance),
                                    separatorLeadingInset: 56
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !sortedSbnInvestments.isEmpty {
                    AssetSectionHeader(
                        title: "Investments",
                        amount: IDRFormatting.compact(investmentPrincipal)
                    )

                    VStack(spacing: 0) {
                        ForEach(sortedSbnInvestments) { investment in
                            Button {
                                activeEditor = .editInvestment(investment.id)
                            } label: {
                                WorthlyDisclosureRow(
                                    icon: "percent",
                                    title: investment.name,
                                    subtitle: "\(IDRFormatting.percent(investment.annualInterestRate)) p.a.",
                                    value: IDRFormatting.compact(investment.principal),
                                    separatorLeadingInset: 56
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if !sortedDebts.isEmpty {
                    AssetSectionHeader(
                        title: "Liabilities",
                        amount: IDRFormatting.compact(totalDebt)
                    )
                    .padding(.top, WorthlySpacing.xs)

                    VStack(spacing: 0) {
                        ForEach(sortedDebts) { debt in
                            Button {
                                activeEditor = .editDebt(debt.id)
                            } label: {
                                WorthlyDisclosureRow(
                                    icon: debt.name.lowercased().contains("kpr") ? "house" : "creditcard",
                                    title: debt.name,
                                    subtitle: "\(debt.durationMonths) months left",
                                    value: IDRFormatting.compact(debt.remainingAmount),
                                    separatorLeadingInset: 56
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, WorthlySpacing.screenHorizontal)
            .padding(.top, WorthlySpacing.xs)
            .padding(.bottom, WorthlySpacing.pageBottom)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Assets")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                WorthlyToolbarIconButton(
                    systemImage: "plus",
                    accessibilityLabel: "Add asset"
                ) {
                    activeEditor = .add(.liquidAccount)
                }
            }
        }
        .fullScreenCover(item: $activeEditor) { editor in
            switch editor {
            case .add(let initialKind):
                AddAssetEditorSheet(
                    initialKind: initialKind,
                    referenceDate: store.referenceDate,
                    onSaveAccount: { store.addAccount($0) },
                    onSaveInvestment: { store.addInvestment($0) },
                    onSaveDebt: { store.addDebt($0) }
                )
            case .editAccount(let accountID):
                if let account = store.accounts.first(where: { $0.id == accountID }) {
                    AssetAccountEditorSheet(account: account) { store.updateAccount($0) }
                } else {
                    AssetMissingEditorSheet(title: "Account not found")
                }
            case .editInvestment(let investmentID):
                if let investment = store.sbnInvestments.first(where: { $0.id == investmentID }) {
                    AssetInvestmentEditorSheet(investment: investment) { store.updateInvestment($0) }
                } else {
                    AssetMissingEditorSheet(title: "Investment not found")
                }
            case .editDebt(let debtID):
                if let debt = store.debts.first(where: { $0.id == debtID }) {
                    AssetDebtEditorSheet(debt: debt) { store.updateDebt($0) }
                } else {
                    AssetMissingEditorSheet(title: "Liability not found")
                }
            }
        }
    }
}

private enum AssetEditor: Identifiable {
    case add(AddAssetKind)
    case editAccount(UUID)
    case editInvestment(UUID)
    case editDebt(UUID)

    var id: String {
        switch self {
        case .add(let kind):
            "add-\(kind.rawValue)"
        case .editAccount(let accountID):
            "edit-account-\(accountID.uuidString)"
        case .editInvestment(let investmentID):
            "edit-investment-\(investmentID.uuidString)"
        case .editDebt(let debtID):
            "edit-debt-\(debtID.uuidString)"
        }
    }
}

#Preview {
    NavigationStack {
        AssetView()
    }
}
