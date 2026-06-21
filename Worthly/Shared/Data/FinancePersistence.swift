//
//  FinancePersistence.swift
//  Worthly
//
//  Created by Codex on 2026/06/16.
//

import Foundation

struct FinanceSnapshot: Codable {
    var referenceDate: Date
    var projectionHorizon: Date
    var accounts: [Account]
    var transactions: [FinanceTransaction]
    var sbnInvestments: [SBNInvestment]
    var debts: [Debt]
    var recurringIncomes: [RecurringIncome]
    var recurringExpenses: [RecurringExpense]
    var checklistActions: [ChecklistAction]
    var netWorthTarget: Decimal
    var hasAnsweredLiabilitySetup: Bool
    var hasCompletedOnboarding: Bool

    enum CodingKeys: String, CodingKey {
        case referenceDate
        case projectionHorizon
        case accounts
        case transactions
        case sbnInvestments
        case debts
        case recurringIncomes
        case recurringExpenses
        case checklistActions
        case netWorthTarget
        case hasAnsweredLiabilitySetup
        case hasCompletedOnboarding
    }

    init(sampleData: SampleFinanceData) {
        referenceDate = sampleData.referenceDate
        projectionHorizon = sampleData.projectionHorizon
        accounts = sampleData.accounts
        transactions = sampleData.transactions
        sbnInvestments = sampleData.sbnInvestments
        debts = sampleData.debts
        recurringIncomes = sampleData.recurringIncomes
        recurringExpenses = sampleData.recurringExpenses
        checklistActions = sampleData.checklistActions
        netWorthTarget = sampleData.netWorthTarget
        hasAnsweredLiabilitySetup = !sampleData.debts.isEmpty
        hasCompletedOnboarding = true
    }

    init(
        referenceDate: Date,
        projectionHorizon: Date,
        accounts: [Account],
        transactions: [FinanceTransaction],
        sbnInvestments: [SBNInvestment],
        debts: [Debt],
        recurringIncomes: [RecurringIncome],
        recurringExpenses: [RecurringExpense],
        checklistActions: [ChecklistAction],
        netWorthTarget: Decimal,
        hasAnsweredLiabilitySetup: Bool,
        hasCompletedOnboarding: Bool
    ) {
        self.referenceDate = referenceDate
        self.projectionHorizon = projectionHorizon
        self.accounts = accounts
        self.transactions = transactions
        self.sbnInvestments = sbnInvestments
        self.debts = debts
        self.recurringIncomes = recurringIncomes
        self.recurringExpenses = recurringExpenses
        self.checklistActions = checklistActions
        self.netWorthTarget = netWorthTarget
        self.hasAnsweredLiabilitySetup = hasAnsweredLiabilitySetup
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        referenceDate = try container.decode(Date.self, forKey: .referenceDate)
        projectionHorizon = try container.decode(Date.self, forKey: .projectionHorizon)
        accounts = try container.decode([Account].self, forKey: .accounts)
        transactions = try container.decode([FinanceTransaction].self, forKey: .transactions)
        sbnInvestments = try container.decode([SBNInvestment].self, forKey: .sbnInvestments)
        debts = try container.decode([Debt].self, forKey: .debts)
        recurringIncomes = try container.decode([RecurringIncome].self, forKey: .recurringIncomes)
        recurringExpenses = try container.decodeIfPresent(
            [RecurringExpense].self,
            forKey: .recurringExpenses
        ) ?? []
        checklistActions = try container.decode([ChecklistAction].self, forKey: .checklistActions)
        netWorthTarget = try container.decode(Decimal.self, forKey: .netWorthTarget)
        hasAnsweredLiabilitySetup = try container.decodeIfPresent(
            Bool.self,
            forKey: .hasAnsweredLiabilitySetup
        ) ?? !debts.isEmpty
        hasCompletedOnboarding = try container.decodeIfPresent(
            Bool.self,
            forKey: .hasCompletedOnboarding
        ) ?? (!accounts.isEmpty && hasAnsweredLiabilitySetup)
    }

    static func empty(referenceDate: Date = Date()) -> FinanceSnapshot {
        let calendar = Calendar.worthly
        let year = calendar.component(.year, from: referenceDate)
        let projectionHorizon = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: 12,
            day: 31,
            hour: 23,
            minute: 59
        ).date ?? referenceDate

        return FinanceSnapshot(
            referenceDate: referenceDate,
            projectionHorizon: projectionHorizon,
            accounts: [],
            transactions: [],
            sbnInvestments: [],
            debts: [],
            recurringIncomes: [],
            recurringExpenses: [],
            checklistActions: [],
            netWorthTarget: 0,
            hasAnsweredLiabilitySetup: false,
            hasCompletedOnboarding: false
        )
    }
}

struct FinancePersistenceState: Codable {
    var activeSnapshot: FinanceSnapshot
    var preservedUserSnapshot: FinanceSnapshot?
    var isDummyDataEnabled: Bool

    init(
        activeSnapshot: FinanceSnapshot,
        preservedUserSnapshot: FinanceSnapshot? = nil,
        isDummyDataEnabled: Bool = false
    ) {
        self.activeSnapshot = activeSnapshot
        self.preservedUserSnapshot = preservedUserSnapshot
        self.isDummyDataEnabled = isDummyDataEnabled
    }
}

struct FinancePersistence {
    static let shared = FinancePersistence()

    private let fileURL: URL

    init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let directory = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0]
                .appendingPathComponent("Worthly", isDirectory: true)

            self.fileURL = directory.appendingPathComponent("finance-data.json")
        }
    }

    func load() -> FinancePersistenceState? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let state = try? decoder.decode(FinancePersistenceState.self, from: data) {
            return state
        }

        if let snapshot = try? decoder.decode(FinanceSnapshot.self, from: data) {
            return FinancePersistenceState(activeSnapshot: snapshot)
        }

        return nil
    }

    func save(_ state: FinancePersistenceState) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(state) else {
            return
        }

        do {
            let directoryURL = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            assertionFailure("Failed to save finance data: \(error)")
        }
    }

    func deleteSavedData() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
