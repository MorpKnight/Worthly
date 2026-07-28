//
//  FinanceStoreTransactionTests.swift
//  WorthlyTests
//
//  Created by Codex on 2026/07/18.
//

import XCTest
@testable import Worthly

final class FinanceStoreTransactionTests: XCTestCase {
    func testAddingTransactionDoesNotChangeCurrentAccountBalance() {
        let store = makeStore()
        let account = makeAccount(name: "Primary", balance: 1_000)
        store.addAccount(account)

        store.addTransaction(
            makeTransaction(type: .income, amount: 250, accountID: account.id)
        )

        XCTAssertEqual(store.accounts.first?.balance, 1_000)
        XCTAssertEqual(store.currentMonthCashflow, 250)
    }

    func testEditingTransactionDoesNotChangeCurrentAccountBalance() {
        let store = makeStore()
        let account = makeAccount(name: "Primary", balance: 1_000)
        store.addAccount(account)
        var transaction = makeTransaction(
            type: .outcome,
            amount: 100,
            accountID: account.id
        )
        store.addTransaction(transaction)

        transaction.amount = 400
        store.updateTransaction(transaction)

        XCTAssertEqual(store.accounts.first?.balance, 1_000)
        XCTAssertEqual(store.currentMonthCashflow, -400)
    }

    func testTransferDoesNotChangeEitherCurrentAccountBalance() {
        let store = makeStore()
        let source = makeAccount(name: "Source", balance: 1_000)
        let destination = makeAccount(name: "Destination", balance: 500)
        store.addAccount(source)
        store.addAccount(destination)

        store.addTransaction(
            makeTransaction(
                type: .account,
                amount: 300,
                accountID: source.id,
                destinationAccountID: destination.id
            )
        )

        XCTAssertEqual(store.accounts.first { $0.id == source.id }?.balance, 1_000)
        XCTAssertEqual(store.accounts.first { $0.id == destination.id }?.balance, 500)
        XCTAssertEqual(store.currentMonthCashflow, 0)
    }

    private func makeStore() -> FinanceStore {
        let referenceDate = date(year: 2026, month: 7, day: 18)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let persistence = FinancePersistence(
            fileURL: directory.appendingPathComponent("finance-data.json")
        )

        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }

        return FinanceStore(persistence: persistence, now: { referenceDate })
    }

    private func makeAccount(name: String, balance: Decimal) -> Account {
        Account(
            id: UUID(),
            name: name,
            type: .bank,
            balance: balance,
            createdAt: date(year: 2026, month: 1, day: 1)
        )
    }

    private func makeTransaction(
        type: FinanceTransactionType,
        amount: Decimal,
        accountID: UUID,
        destinationAccountID: UUID? = nil
    ) -> FinanceTransaction {
        FinanceTransaction(
            id: UUID(),
            type: type,
            amount: amount,
            category: type == .income ? "Salary" : "Transfer",
            accountID: accountID,
            destinationAccountID: destinationAccountID,
            date: date(year: 2026, month: 7, day: 18),
            note: ""
        )
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        DateComponents(
            calendar: .worthly,
            timeZone: Calendar.worthly.timeZone,
            year: year,
            month: month,
            day: day,
            hour: 12
        ).date!
    }
}
