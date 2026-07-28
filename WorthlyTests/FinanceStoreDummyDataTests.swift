//
//  FinanceStoreDummyDataTests.swift
//  WorthlyTests
//
//  Created by Codex on 2026/07/18.
//

import XCTest
@testable import Worthly

final class FinanceStoreDummyDataTests: XCTestCase {
    func testSampleExplorationRestoresEmptyOnboardingStateWhenDisabled() {
        let referenceDate = date(year: 2026, month: 7, day: 18)
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let persistence = FinancePersistence(
            fileURL: directory.appendingPathComponent("finance-data.json")
        )
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        let store = FinanceStore(
            persistence: persistence,
            now: { referenceDate }
        )

        store.enableDummyData()

        XCTAssertTrue(store.isDummyDataEnabled)
        XCTAssertTrue(store.hasCompletedOnboarding)
        XCTAssertFalse(store.accounts.isEmpty)

        store.disableDummyData()

        XCTAssertFalse(store.isDummyDataEnabled)
        XCTAssertFalse(store.hasCompletedOnboarding)
        XCTAssertTrue(store.accounts.isEmpty)
        XCTAssertEqual(store.referenceDate, referenceDate)
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
