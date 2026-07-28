//
//  FinanceStoreDateTests.swift
//  WorthlyTests
//
//  Created by Codex on 2026/07/18.
//

import XCTest
@testable import Worthly

final class FinanceStoreDateTests: XCTestCase {
    func testLiveStoreUsesCurrentDateInsteadOfPersistedReferenceDate() {
        let persistedReferenceDate = date(year: 2026, month: 6, day: 15)
        let currentDate = date(year: 2027, month: 1, day: 10)
        let persistence = temporaryPersistence()
        persistence.save(
            FinancePersistenceState(
                activeSnapshot: .empty(referenceDate: persistedReferenceDate)
            )
        )

        let store = FinanceStore(persistence: persistence, now: { currentDate })

        XCTAssertEqual(store.referenceDate, currentDate)
        XCTAssertEqual(
            store.projectionHorizon,
            date(year: 2027, month: 12, day: 31, hour: 23, minute: 59)
        )
    }

    func testRefreshReferenceDateUsesInjectedClock() {
        var currentDate = date(year: 2026, month: 7, day: 18)
        let store = FinanceStore(
            persistence: temporaryPersistence(),
            now: { currentDate }
        )

        currentDate = date(year: 2026, month: 8, day: 1)
        store.refreshReferenceDate()

        XCTAssertEqual(store.referenceDate, currentDate)
    }

    func testSampleStoreKeepsDeterministicReferenceDate() {
        let futureDate = date(year: 2030, month: 1, day: 1)
        let store = FinanceStore(
            sampleData: .current,
            persistence: temporaryPersistence(),
            now: { futureDate }
        )

        let sampleReferenceDate = store.referenceDate
        store.refreshReferenceDate()

        XCTAssertEqual(store.referenceDate, sampleReferenceDate)
        XCTAssertNotEqual(store.referenceDate, futureDate)
    }

    func testDisablingDummyDataRestoresLiveReferenceDate() {
        var currentDate = date(year: 2026, month: 7, day: 18)
        let store = FinanceStore(
            persistence: temporaryPersistence(),
            now: { currentDate }
        )

        store.enableDummyData()
        let dummyReferenceDate = store.referenceDate
        currentDate = date(year: 2027, month: 2, day: 1)
        store.refreshReferenceDate()

        XCTAssertEqual(store.referenceDate, dummyReferenceDate)

        store.disableDummyData()

        XCTAssertEqual(store.referenceDate, currentDate)
        XCTAssertGreaterThanOrEqual(store.projectionHorizon, currentDate)
    }

    func testReferenceMonthUsesJakartaCalendar() {
        let referenceDate = date(year: 2026, month: 7, day: 31, hour: 23)
        let startOfMonth = date(year: 2026, month: 7, day: 1, minute: 30)
        let store = FinanceStore(
            persistence: temporaryPersistence(),
            now: { referenceDate }
        )

        XCTAssertTrue(store.isInReferenceMonth(startOfMonth))
    }

    private func temporaryPersistence() -> FinancePersistence {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directory.appendingPathComponent("finance-data.json")

        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }

        return FinancePersistence(fileURL: fileURL)
    }

    private func date(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        minute: Int = 0
    ) -> Date {
        DateComponents(
            calendar: .worthly,
            timeZone: Calendar.worthly.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        ).date!
    }
}
