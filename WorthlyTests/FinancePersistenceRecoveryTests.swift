//
//  FinancePersistenceRecoveryTests.swift
//  WorthlyTests
//
//  Created by Codex on 2026/07/18.
//

import XCTest
@testable import Worthly

final class FinancePersistenceRecoveryTests: XCTestCase {
    func testCorruptedPrimaryFileRecoversFromBackup() {
        let context = temporaryPersistence()
        let state = FinancePersistenceState(
            activeSnapshot: .empty(referenceDate: testDate)
        )
        context.persistence.save(state)
        try! Data("corrupted".utf8).write(to: context.fileURL, options: [.atomic])

        guard case .recoveredFromBackup(let recoveredState) = context.persistence.loadResult() else {
            return XCTFail("Expected the backup snapshot to be recovered")
        }

        XCTAssertEqual(
            recoveredState.activeSnapshot.referenceDate,
            state.activeSnapshot.referenceDate
        )
    }

    func testUnreadableFilesAreNotSilentlyOverwrittenDuringStoreInitialization() throws {
        let context = temporaryPersistence()
        try FileManager.default.createDirectory(
            at: context.directory,
            withIntermediateDirectories: true
        )
        let corruptedData = Data("corrupted".utf8)
        try corruptedData.write(to: context.fileURL, options: [.atomic])

        let store = FinanceStore(
            persistence: context.persistence,
            now: { self.testDate }
        )

        XCTAssertEqual(store.dataRecoveryStatus, .unreadable)
        XCTAssertEqual(try Data(contentsOf: context.fileURL), corruptedData)
    }

    func testResetUnreadableDataRequiresExplicitRecoveryAction() throws {
        let context = temporaryPersistence()
        try FileManager.default.createDirectory(
            at: context.directory,
            withIntermediateDirectories: true
        )
        try Data("corrupted".utf8).write(to: context.fileURL, options: [.atomic])
        let store = FinanceStore(
            persistence: context.persistence,
            now: { self.testDate }
        )

        store.resetUnreadableData()

        XCTAssertNil(store.dataRecoveryStatus)
        guard case .loaded(let state) = context.persistence.loadResult() else {
            return XCTFail("Expected reset to create a readable empty state")
        }
        XCTAssertTrue(state.activeSnapshot.accounts.isEmpty)
        XCTAssertEqual(state.schemaVersion, FinancePersistenceState.currentSchemaVersion)
    }

    func testStateWithoutSchemaVersionLoadsAsVersionOne() throws {
        let context = temporaryPersistence()
        try FileManager.default.createDirectory(
            at: context.directory,
            withIntermediateDirectories: true
        )
        let legacyState = LegacyPersistenceState(
            activeSnapshot: .empty(referenceDate: testDate),
            preservedUserSnapshot: nil,
            isDummyDataEnabled: false
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(legacyState).write(to: context.fileURL, options: [.atomic])

        guard case .loaded(let state) = context.persistence.loadResult() else {
            return XCTFail("Expected legacy state to load")
        }

        XCTAssertEqual(state.schemaVersion, 1)
    }

    private var testDate: Date {
        DateComponents(
            calendar: .worthly,
            timeZone: Calendar.worthly.timeZone,
            year: 2026,
            month: 7,
            day: 18,
            hour: 12
        ).date!
    }

    private func temporaryPersistence() -> PersistenceTestContext {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directory.appendingPathComponent("finance-data.json")

        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }

        return PersistenceTestContext(
            directory: directory,
            fileURL: fileURL,
            persistence: FinancePersistence(fileURL: fileURL)
        )
    }
}

private struct PersistenceTestContext {
    let directory: URL
    let fileURL: URL
    let persistence: FinancePersistence
}

private struct LegacyPersistenceState: Encodable {
    let activeSnapshot: FinanceSnapshot
    let preservedUserSnapshot: FinanceSnapshot?
    let isDummyDataEnabled: Bool
}
