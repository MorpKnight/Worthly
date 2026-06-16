//
//  SampleFinanceData.swift
//  Worthly
//
//  Created by Giovan Christoffel Sihombing on 2026/06/15.
//

import Foundation

struct SampleFinanceData {
    let referenceDate: Date
    let projectionHorizon: Date
    let accounts: [Account]
    let transactions: [FinanceTransaction]
    let sbnInvestments: [SBNInvestment]
    let debts: [Debt]
    let recurringIncomes: [RecurringIncome]
    let checklistActions: [ChecklistAction]
    let netWorthTarget: Decimal

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

    var netWorthChangeText: String {
        "+12.4%"
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

    var monthlyDebtInstallment: Decimal {
        debts.reduce(0) { $0 + $1.estimatedMonthlyInstallment }
    }

    var projectedNetWorth: Decimal {
        let paymentCount = Decimal(projectedPaymentCount)

        return currentNetWorth
            + (monthlySalary * paymentCount)
            + (monthlySbnCoupon * paymentCount)
            - (monthlyDebtInstallment * paymentCount)
    }

    var gapToTarget: Decimal {
        projectedNetWorth - netWorthTarget
    }

    var referenceMonthSummary: (total: Decimal, count: Int) {
        let monthTransactions = transactions.filter { isInReferenceMonth($0.date) }
        let total = monthTransactions.reduce(0) { $0 + $1.cashflowAmount }

        return (total, monthTransactions.count)
    }

    static let current: SampleFinanceData = {
        let bcaID = UUID()
        let mandiriID = UUID()
        let jagoID = UUID()
        let bniID = UUID()
        let seabankID = UUID()
        let gopayID = UUID()
        let shopeePayID = UUID()
        let cashID = UUID()

        let accounts = [
            Account(id: bcaID, name: "Bank Central Asia", type: .bank, balance: 38_750_000, createdAt: date(year: 2025, month: 1, day: 4)),
            Account(id: mandiriID, name: "Bank Mandiri", type: .bank, balance: 18_200_000, createdAt: date(year: 2025, month: 2, day: 12)),
            Account(id: jagoID, name: "Bank Jago", type: .bank, balance: 14_500_000, createdAt: date(year: 2025, month: 3, day: 7)),
            Account(id: bniID, name: "BNI Emergency", type: .bank, balance: 24_000_000, createdAt: date(year: 2024, month: 9, day: 18)),
            Account(id: seabankID, name: "SeaBank", type: .bank, balance: 9_750_000, createdAt: date(year: 2025, month: 8, day: 28)),
            Account(id: gopayID, name: "Gopay", type: .eWallet, balance: 1_150_000, createdAt: date(year: 2025, month: 5, day: 9)),
            Account(id: shopeePayID, name: "ShopeePay", type: .eWallet, balance: 650_000, createdAt: date(year: 2025, month: 7, day: 3)),
            Account(id: cashID, name: "Cash on hand", type: .cash, balance: 1_500_000, createdAt: date(year: 2025, month: 10, day: 22))
        ]

        let investments = [
            SBNInvestment(id: UUID(), name: "ORI04ST26", principal: 50_000_000, annualInterestRate: decimal("6.25"), durationMonths: 36, startDate: date(year: 2026, month: 2, day: 10)),
            SBNInvestment(id: UUID(), name: "SBR013T2", principal: 35_000_000, annualInterestRate: decimal("6.45"), durationMonths: 24, startDate: date(year: 2025, month: 6, day: 20)),
            SBNInvestment(id: UUID(), name: "ST012T4", principal: 25_000_000, annualInterestRate: decimal("6.35"), durationMonths: 48, startDate: date(year: 2025, month: 11, day: 8)),
            SBNInvestment(id: UUID(), name: "SR020T3", principal: 18_000_000, annualInterestRate: decimal("6.30"), durationMonths: 36, startDate: date(year: 2026, month: 3, day: 16)),
            SBNInvestment(id: UUID(), name: "ST011T2", principal: 14_000_000, annualInterestRate: decimal("6.10"), durationMonths: 24, startDate: date(year: 2025, month: 9, day: 3)),
            SBNInvestment(id: UUID(), name: "ORI025T3", principal: 12_000_000, annualInterestRate: decimal("6.25"), durationMonths: 36, startDate: date(year: 2026, month: 5, day: 21))
        ]

        let debts = [
            Debt(id: UUID(), name: "KPR rumah", remainingAmount: 39_000_000, annualInterestRate: decimal("7.50"), durationMonths: 180, startDate: date(year: 2024, month: 4, day: 1)),
            Debt(id: UUID(), name: "MacBook installment", remainingAmount: 3_200_000, annualInterestRate: 0, durationMonths: 8, startDate: date(year: 2026, month: 1, day: 18)),
            Debt(id: UUID(), name: "Phone cicilan", remainingAmount: 1_800_000, annualInterestRate: 0, durationMonths: 6, startDate: date(year: 2026, month: 3, day: 2)),
            Debt(id: UUID(), name: "Credit card", remainingAmount: 2_400_000, annualInterestRate: decimal("2.50"), durationMonths: 10, startDate: date(year: 2026, month: 4, day: 11)),
            Debt(id: UUID(), name: "Family loan", remainingAmount: 5_000_000, annualInterestRate: 0, durationMonths: 12, startDate: date(year: 2025, month: 12, day: 5))
        ]

        let transactions = [
            transaction(.income, 13_500_000, "Salary", bcaID, 15, 9, 5, "Monthly salary"),
            transaction(.income, 675_000, "SBN coupon", bcaID, 15, 8, 30, "Monthly SBN coupon"),
            transaction(.outcome, 300_000, "Restaurant", bcaID, 15, 12, 40, "Lunch with team"),
            transaction(.outcome, 1_300_000, "Debt installment", mandiriID, 15, 10, 12, "Digimap installment"),
            transaction(.account, 1_000_000, "Gopay top up", gopayID, 15, 7, 48, "Top up from BCA"),
            transaction(.outcome, 45_000, "Coffee", gopayID, 15, 7, 28, "Morning coffee"),
            transaction(.outcome, 3_500_000, "Travel", mandiriID, 14, 20, 30, "Flight ticket"),
            transaction(.outcome, 150_000, "Phone", bcaID, 14, 18, 15, "Monthly phone package"),
            transaction(.income, 2_000_000, "Freelance", jagoID, 14, 16, 45, "Landing page copy"),
            transaction(.outcome, 820_000, "Groceries", bcaID, 14, 11, 10, "Weekly groceries"),
            transaction(.account, 4_000_000, "Transfer", bcaID, 14, 9, 15, "Move emergency cash"),
            transaction(.outcome, 75_000, "Laundry", cashID, 14, 8, 10, "Laundry"),
            transaction(.outcome, 410_000, "Transport", gopayID, 13, 21, 8, "Ride share"),
            transaction(.outcome, 265_000, "Restaurant", shopeePayID, 13, 19, 20, "Dinner"),
            transaction(.outcome, 1_250_000, "Shopping", mandiriID, 13, 15, 55, "Work shoes"),
            transaction(.income, 350_000, "Cashback", shopeePayID, 13, 13, 5, "Promo cashback"),
            transaction(.outcome, 125_000, "Coffee", gopayID, 13, 9, 42, "Cafe work session"),
            transaction(.outcome, 640_000, "Groceries", bcaID, 12, 20, 5, "House supplies"),
            transaction(.outcome, 95_000, "Transport", gopayID, 12, 17, 30, "Train and ride"),
            transaction(.outcome, 2_100_000, "Education", bcaID, 12, 10, 5, "Course installment"),
            transaction(.account, 2_500_000, "Transfer", seabankID, 12, 8, 25, "Savings sweep"),
            transaction(.outcome, 55_000, "Coffee", cashID, 11, 17, 0, "Coffee"),
            transaction(.outcome, 275_000, "Health", bcaID, 11, 15, 45, "Medicine"),
            transaction(.outcome, 1_900_000, "Rent", mandiriID, 11, 9, 5, "Studio rent"),
            transaction(.income, 675_000, "SBN coupon", bcaID, 10, 8, 35, "Monthly SBN coupon"),
            transaction(.outcome, 380_000, "Restaurant", gopayID, 10, 20, 15, "Dinner"),
            transaction(.outcome, 230_000, "Internet", bcaID, 10, 13, 10, "Home internet"),
            transaction(.income, 1_000_000, "Side project", jagoID, 10, 11, 30, "Prototype milestone"),
            transaction(.outcome, 480_000, "Groceries", bcaID, 9, 19, 45, "Market"),
            transaction(.account, 750_000, "Top up", gopayID, 9, 18, 20, "Wallet refill"),
            transaction(.outcome, 67_000, "Transport", gopayID, 9, 8, 15, "Commute"),
            transaction(.outcome, 1_100_000, "Debt installment", bcaID, 8, 10, 0, "Credit card payment"),
            transaction(.outcome, 340_000, "Shopping", shopeePayID, 8, 13, 50, "Desk accessories"),
            transaction(.outcome, 42_000, "Coffee", gopayID, 8, 9, 10, "Coffee"),
            transaction(.outcome, 710_000, "Groceries", bcaID, 7, 18, 25, "Groceries"),
            transaction(.outcome, 225_000, "Restaurant", bcaID, 7, 12, 35, "Lunch"),
            transaction(.income, 500_000, "Gift", bcaID, 6, 16, 0, "Family gift"),
            transaction(.outcome, 1_450_000, "Travel", mandiriID, 6, 9, 45, "Hotel deposit"),
            transaction(.outcome, 90_000, "Transport", gopayID, 5, 19, 0, "Ride share"),
            transaction(.outcome, 310_000, "Health", bcaID, 5, 13, 10, "Clinic"),
            transaction(.account, 3_000_000, "Transfer", bniID, 4, 8, 30, "Emergency fund"),
            transaction(.outcome, 88_000, "Coffee", gopayID, 4, 7, 55, "Cafe"),
            transaction(.outcome, 560_000, "Groceries", bcaID, 3, 20, 12, "Monthly stock"),
            transaction(.outcome, 125_000, "Phone", bcaID, 3, 11, 8, "Data package"),
            transaction(.income, 13_500_000, "Salary", bcaID, 1, 9, 0, "Backfilled May salary paid late"),
            transaction(.outcome, 3_200_000, "Debt installment", mandiriID, 1, 8, 45, "KPR payment")
        ]

        return SampleFinanceData(
            referenceDate: date(year: 2026, month: 6, day: 15, hour: 12),
            projectionHorizon: date(year: 2026, month: 12, day: 31, hour: 23, minute: 59),
            accounts: accounts,
            transactions: transactions,
            sbnInvestments: investments,
            debts: debts,
            recurringIncomes: [
                RecurringIncome(id: UUID(), name: "Monthly salary", amount: 13_500_000, payday: 25)
            ],
            checklistActions: [
                ChecklistAction(id: UUID(), title: "Add salary", isCompleted: true),
                ChecklistAction(id: UUID(), title: "Add investment", isCompleted: true),
                ChecklistAction(id: UUID(), title: "Add debt", isCompleted: true)
            ],
            netWorthTarget: 320_000_000
        )
    }()

    func accountName(for id: UUID) -> String {
        accounts.first { $0.id == id }?.name ?? "Unknown"
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

    private var projectedPaymentCount: Int {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.dateInterval(of: .month, for: referenceDate)?.start ?? referenceDate
        let end = calendar.dateInterval(of: .month, for: projectionHorizon)?.start ?? projectionHorizon
        let months = calendar.dateComponents([.month], from: start, to: end).month ?? 0

        return max(months + 1, 0)
    }

    private func isInReferenceMonth(_ date: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let referenceComponents = calendar.dateComponents([.year, .month], from: referenceDate)
        let dateComponents = calendar.dateComponents([.year, .month], from: date)

        return referenceComponents.year == dateComponents.year
            && referenceComponents.month == dateComponents.month
    }

    private static func transaction(
        _ type: FinanceTransactionType,
        _ amount: Decimal,
        _ category: String,
        _ accountID: UUID,
        _ day: Int,
        _ hour: Int,
        _ minute: Int,
        _ note: String
    ) -> FinanceTransaction {
        FinanceTransaction(
            id: UUID(),
            type: type,
            amount: amount,
            category: category,
            accountID: accountID,
            date: date(year: 2026, month: 6, day: day, hour: hour, minute: minute),
            note: note
        )
    }

    private static func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 9,
        minute: Int = 0
    ) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Jakarta") ?? .current

        return DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        ).date ?? Date(timeIntervalSince1970: 0)
    }

    private static func decimal(_ string: String) -> Decimal {
        Decimal(string: string, locale: Locale(identifier: "en_US_POSIX")) ?? 0
    }
}
