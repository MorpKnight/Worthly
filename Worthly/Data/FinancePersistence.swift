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
    var checklistActions: [ChecklistAction]
    var netWorthTarget: Decimal

    init(sampleData: SampleFinanceData) {
        referenceDate = sampleData.referenceDate
        projectionHorizon = sampleData.projectionHorizon
        accounts = sampleData.accounts
        transactions = sampleData.transactions
        sbnInvestments = sampleData.sbnInvestments
        debts = sampleData.debts
        recurringIncomes = sampleData.recurringIncomes
        checklistActions = sampleData.checklistActions
        netWorthTarget = sampleData.netWorthTarget
    }

    init(
        referenceDate: Date,
        projectionHorizon: Date,
        accounts: [Account],
        transactions: [FinanceTransaction],
        sbnInvestments: [SBNInvestment],
        debts: [Debt],
        recurringIncomes: [RecurringIncome],
        checklistActions: [ChecklistAction],
        netWorthTarget: Decimal
    ) {
        self.referenceDate = referenceDate
        self.projectionHorizon = projectionHorizon
        self.accounts = accounts
        self.transactions = transactions
        self.sbnInvestments = sbnInvestments
        self.debts = debts
        self.recurringIncomes = recurringIncomes
        self.checklistActions = checklistActions
        self.netWorthTarget = netWorthTarget
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

    func load() -> FinanceSnapshot? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try? decoder.decode(FinanceSnapshot.self, from: data)
    }

    func save(_ snapshot: FinanceSnapshot) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(snapshot) else {
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
