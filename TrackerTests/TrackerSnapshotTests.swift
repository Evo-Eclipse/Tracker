//
//  TrackerSnapshotTests.swift
//  Tracker
//
//  Created by Pavel Komarov on 14.08.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerSnapshotTests: XCTestCase {

    // MARK: - Configuration

    // Set to true to overwrite all reference snapshots
    private let shouldRecordSnapshots = false

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTrackersViewControllerLightTheme() throws {
        let viewController = TrackersViewController()
        viewController.overrideUserInterfaceStyle = .light

        withSnapshotTesting(record: shouldRecordSnapshots ? .all : .missing) {
            assertSnapshots(of: viewController, as: [
                .image(on: .iPhone12),
                .image(on: .iPhoneSe)
            ])
        }
    }

    func testTrackersViewControllerDarkTheme() throws {
        let viewController = TrackersViewController()
        viewController.overrideUserInterfaceStyle = .dark

        withSnapshotTesting(record: shouldRecordSnapshots ? .all : .missing) {
            assertSnapshots(of: viewController, as: [
                .image(on: .iPhone12),
                .image(on: .iPhoneSe)
            ])
        }
    }
}
