//
//  FinanceStore.swift
//  Worthly
//
//  Created by Codex on 2026/06/16.
//

import Foundation
import Observation

@Observable
final class FinanceStore {
    @ObservationIgnored private let persistence: FinancePersistence
    @ObservationIgnored private var shouldPersist = false
    @ObservationIgnored private var preservedUserSnapshot: FinanceSnapshot?

    var referenceDate: Date {
        didSet { persistIfNeeded() }
    }
    var projectionHorizon: Date {
        didSet { persistIfNeeded() }
    }
    var accounts: [Account] {
        didSet { persistIfNeeded() }
    }
    var transactions: [FinanceTransaction] {
        didSet { persistIfNeeded() }
    }
    var sbnInvestments: [SBNInvestment] {
        didSet { persistIfNeeded() }
    }
    var debts: [Debt] {
        didSet { persistIfNeeded() }
    }
    var recurringIncomes: [RecurringIncome] {
        didSet { persistIfNeeded() }
    }
    var recurringExpenses: [RecurringExpense] {
        didSet { persistIfNeeded() }
    }
    var checklistActions: [ChecklistAction] {
        didSet { persistIfNeeded() }
    }
    var netWorthTarget: Decimal {
        didSet { persistIfNeeded() }
    }
    var hasAnsweredLiabilitySetup: Bool {
        didSet { persistIfNeeded() }
    }
    var hasCompletedOnboarding: Bool {
        didSet { persistIfNeeded() }
    }
    var isDummyDataEnabled: Bool {
        didSet { persistIfNeeded() }
    }

    init(
        sampleData: SampleFinanceData? = nil,
        persistence: FinancePersistence = .shared
    ) {
        self.persistence = persistence

        let state = persistence.load()
            ?? FinancePersistenceState(
                activeSnapshot: sampleData.map { FinanceSnapshot(sampleData: $0) } ?? FinanceSnapshot.empty()
            )
        let snapshot = state.activeSnapshot
        referenceDate = snapshot.referenceDate
        projectionHorizon = snapshot.projectionHorizon
        accounts = snapshot.accounts
        transactions = snapshot.transactions
        sbnInvestments = snapshot.sbnInvestments
        debts = snapshot.debts
        recurringIncomes = snapshot.recurringIncomes
        recurringExpenses = snapshot.recurringExpenses
        checklistActions = snapshot.checklistActions
        netWorthTarget = snapshot.netWorthTarget
        hasAnsweredLiabilitySetup = snapshot.hasAnsweredLiabilitySetup
        hasCompletedOnboarding = snapshot.hasCompletedOnboarding
        preservedUserSnapshot = state.preservedUserSnapshot
        isDummyDataEnabled = state.isDummyDataEnabled
        shouldPersist = true
    }

    var liquidAssets: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }

    var investmentPrincipal: Decimal {
        sbnInvestments.reduce(0) { $0 + $1.principal }
    }

    var totalAssets: Decimal {
        liquidAssets + investmentPrincipal
    }

    var totalDebt: Decimal {
        debts.reduce(0) { $0 + $1.remainingAmount }
    }

    var currentNetWorth: Decimal {
        totalAssets - totalDebt
    }

    var hasStartedMoneyMap: Bool {
        !accounts.isEmpty || !sbnInvestments.isEmpty || !debts.isEmpty
    }

    var isInitialSetupComplete: Bool {
        !accounts.isEmpty && (!debts.isEmpty || hasAnsweredLiabilitySetup)
    }

    var canCompleteOnboarding: Bool {
        !accounts.isEmpty && (!debts.isEmpty || hasAnsweredLiabilitySetup)
    }

    var netWorthChangeText: String {
        let openingNetWorth = currentNetWorth - currentMonthCashflow

        guard openingNetWorth != 0 else {
            return IDRFormatting.signedPercent(0)
        }

        let percentage = currentMonthCashflow / absolute(openingNetWorth) * 100

        return IDRFormatting.signedPercent(percentage)
    }

    var currentMonthCashflow: Decimal {
        transactions
            .filter { isInReferenceMonth($0.date) }
            .reduce(0) { $0 + $1.cashflowAmount }
    }

    var recentTransactions: [FinanceTransaction] {
        transactions.sorted { $0.date > $1.date }
    }

    var monthlySalary: Decimal {
        recurringIncomes.reduce(0) { $0 + $1.amount }
    }

    var monthlySbnCoupon: Decimal {
        sbnInvestments.reduce(0) { $0 + $1.estimatedMonthlyCoupon }
    }

    var monthlyRecurringExpenses: Decimal {
        recurringExpenses.reduce(0) { $0 + $1.amount }
    }

    var monthlyDebtInstallment: Decimal {
        debts.reduce(0) { $0 + $1.estimatedMonthlyInstallment }
    }

    var planningProjection: PlanningProjectionSummary {
        PlanningProjectionEngine.project(
            referenceDate: referenceDate,
            projectionHorizon: projectionHorizon,
            liquidAssets: liquidAssets,
            investmentPrincipal: investmentPrincipal,
            debts: debts,
            recurringIncomes: recurringIncomes,
            recurringExpenses: recurringExpenses,
            investments: sbnInvestments,
            netWorthTarget: netWorthTarget
        )
    }

    var projectedNetWorth: Decimal {
        planningProjection.projectedNetWorth
    }

    var gapToTarget: Decimal {
        planningProjection.gapToTarget
    }

    var referenceMonthSummary: (total: Decimal, count: Int) {
        let monthTransactions = transactions.filter { isInReferenceMonth($0.date) }
        let total = monthTransactions.reduce(0) { $0 + $1.cashflowAmount }

        return (total, monthTransactions.count)
    }

    func accountName(for id: UUID) -> String {
        accounts.first { $0.id == id }?.name ?? "Unknown"
    }

    func destinationAccountName(for transaction: FinanceTransaction) -> String? {
        guard let destinationAccountID = transaction.destinationAccountID else {
            return nil
        }

        return accountName(for: destinationAccountID)
    }

    func transactions(for filter: FinanceTransactionType?) -> [FinanceTransaction] {
        let filteredTransactions: [FinanceTransaction]

        if let filter {
            filteredTransactions = transactions.filter { $0.type == filter }
        } else {
            filteredTransactions = transactions
        }

        return filteredTransactions.sorted { $0.date > $1.date }
    }

    func groupedTransactions(for transactions: [FinanceTransaction]) -> [FinanceTransactionGroup] {
        var groups: [FinanceTransactionGroup] = []

        for transaction in transactions {
            let title = WorthlyDateFormatting.historySectionTitle(
                for: transaction.date,
                referenceDate: referenceDate
            )

            if let index = groups.firstIndex(where: { $0.title == title }) {
                groups[index].transactions.append(transaction)
            } else {
                groups.append(
                    FinanceTransactionGroup(
                        id: title,
                        title: title,
                        transactions: [transaction]
                    )
                )
            }
        }

        return groups
    }

    func addAccount(_ account: Account) {
        accounts.append(account)
    }

    func updateAccount(_ account: Account) {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else {
            return
        }

        accounts[index] = account
    }

    func addInvestment(_ investment: SBNInvestment) {
        sbnInvestments.append(investment)
    }

    func updateInvestment(_ investment: SBNInvestment) {
        guard let index = sbnInvestments.firstIndex(where: { $0.id == investment.id }) else {
            return
        }

        sbnInvestments[index] = investment
    }

    func updateDebt(_ debt: Debt) {
        guard let index = debts.firstIndex(where: { $0.id == debt.id }) else {
            return
        }

        debts[index] = debt
        hasAnsweredLiabilitySetup = true
    }

    func addDebt(_ debt: Debt) {
        debts.append(debt)
        hasAnsweredLiabilitySetup = true
    }

    func confirmNoLiabilities() {
        hasAnsweredLiabilitySetup = true
    }

    func completeOnboarding() {
        guard canCompleteOnboarding else {
            return
        }

        hasCompletedOnboarding = true
    }

    func setDummyDataEnabled(_ isEnabled: Bool) {
        isEnabled ? enableDummyData() : disableDummyData()
    }

    func enableDummyData() {
        guard !isDummyDataEnabled else {
            return
        }

        let userSnapshot = snapshot
        let dummySnapshot = FinanceSnapshot(sampleData: .current)

        shouldPersist = false
        applySnapshot(dummySnapshot)
        preservedUserSnapshot = userSnapshot
        isDummyDataEnabled = true
        shouldPersist = true
        persistence.save(persistenceState)
    }

    func disableDummyData() {
        guard isDummyDataEnabled else {
            return
        }

        let restoredSnapshot = preservedUserSnapshot ?? FinanceSnapshot.empty()

        shouldPersist = false
        applySnapshot(restoredSnapshot)
        preservedUserSnapshot = nil
        isDummyDataEnabled = false
        shouldPersist = true
        persistence.save(persistenceState)
    }

    func saveSalaryAmounts(_ amounts: [Decimal]) {
        recurringIncomes = amounts.enumerated().map { index, amount in
            if recurringIncomes.indices.contains(index) {
                var income = recurringIncomes[index]
                income.amount = amount

                return income
            }

            return RecurringIncome(
                id: UUID(),
                name: "Monthly salary \(index + 1)",
                amount: amount,
                payday: 25
            )
        }
    }

    func saveRecurringExpenses(_ expenses: [RecurringExpense]) {
        recurringExpenses = expenses
    }

    func addTransaction(_ transaction: FinanceTransaction) {
        transactions.append(transaction)
        applyBalanceEffect(of: transaction)
    }

    func updateTransaction(_ transaction: FinanceTransaction) {
        guard let index = transactions.firstIndex(where: { $0.id == transaction.id }) else {
            return
        }

        let oldTransaction = transactions[index]
        applyBalanceEffect(of: oldTransaction, multiplier: -1)
        transactions[index] = transaction
        applyBalanceEffect(of: transaction)
    }

    func resetToSampleData(_ sampleData: SampleFinanceData = .current) {
        shouldPersist = false
        applySnapshot(FinanceSnapshot(sampleData: sampleData))
        preservedUserSnapshot = nil
        isDummyDataEnabled = false
        shouldPersist = true
        persistence.save(persistenceState)
    }

    func resetToEmptyData() {
        shouldPersist = false
        applySnapshot(FinanceSnapshot.empty())
        preservedUserSnapshot = nil
        isDummyDataEnabled = false
        shouldPersist = true
        persistence.save(persistenceState)
    }

    func isInReferenceMonth(_ date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let referenceComponents = calendar.dateComponents([.year, .month], from: referenceDate)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)

        return referenceComponents.year == dateComponents.year
            && referenceComponents.month == dateComponents.month
    }

    private var snapshot: FinanceSnapshot {
        FinanceSnapshot(
            referenceDate: referenceDate,
            projectionHorizon: projectionHorizon,
            accounts: accounts,
            transactions: transactions,
            sbnInvestments: sbnInvestments,
            debts: debts,
            recurringIncomes: recurringIncomes,
            recurringExpenses: recurringExpenses,
            checklistActions: checklistActions,
            netWorthTarget: netWorthTarget,
            hasAnsweredLiabilitySetup: hasAnsweredLiabilitySetup,
            hasCompletedOnboarding: hasCompletedOnboarding
        )
    }

    private var persistenceState: FinancePersistenceState {
        FinancePersistenceState(
            activeSnapshot: snapshot,
            preservedUserSnapshot: preservedUserSnapshot,
            isDummyDataEnabled: isDummyDataEnabled
        )
    }

    private func persistIfNeeded() {
        guard shouldPersist else {
            return
        }

        persistence.save(persistenceState)
    }

    private func applySnapshot(_ snapshot: FinanceSnapshot) {
        referenceDate = snapshot.referenceDate
        projectionHorizon = snapshot.projectionHorizon
        accounts = snapshot.accounts
        transactions = snapshot.transactions
        sbnInvestments = snapshot.sbnInvestments
        debts = snapshot.debts
        recurringIncomes = snapshot.recurringIncomes
        recurringExpenses = snapshot.recurringExpenses
        checklistActions = snapshot.checklistActions
        netWorthTarget = snapshot.netWorthTarget
        hasAnsweredLiabilitySetup = snapshot.hasAnsweredLiabilitySetup
        hasCompletedOnboarding = snapshot.hasCompletedOnboarding
    }

    private func absolute(_ amount: Decimal) -> Decimal {
        amount < 0 ? -amount : amount
    }

    private func applyBalanceEffect(of transaction: FinanceTransaction, multiplier: Decimal = 1) {
        switch transaction.type {
        case .income:
            adjustAccountBalance(
                accountID: transaction.accountID,
                amount: transaction.amount * multiplier
            )
        case .outcome:
            adjustAccountBalance(
                accountID: transaction.accountID,
                amount: -transaction.amount * multiplier
            )
        case .account:
            guard let destinationAccountID = transaction.destinationAccountID,
                  destinationAccountID != transaction.accountID else {
                return
            }

            adjustAccountBalance(
                accountID: transaction.accountID,
                amount: -transaction.amount * multiplier
            )
            adjustAccountBalance(
                accountID: destinationAccountID,
                amount: transaction.amount * multiplier
            )
        }
    }

    private func adjustAccountBalance(accountID: UUID, amount: Decimal) {
        guard amount != 0,
              let index = accounts.firstIndex(where: { $0.id == accountID }) else {
            return
        }

        accounts[index].balance += amount
    }
}
