//
//  StoreProvider.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//
 
import UIKit
import CoreData

// MARK: - StoreProvider

final class StoreProvider {

    // MARK: - Static Properties

    static let shared = StoreProvider()

    // MARK: - Public Properties

    let trackerStore: TrackerStore
    let categoryStore: TrackerCategoryStore
    let recordStore: TrackerRecordStore

    // MARK: - Initializers

    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate is not available")
        }
        let container = appDelegate.persistentContainer
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true

        self.categoryStore = TrackerCategoryStore(container: container)
        self.trackerStore = TrackerStore(container: container)
        self.recordStore = TrackerRecordStore(container: container)
        
        // Print of all trackers for debugging purposes
        print("All trackers: \(trackerStore.snapshotFiltered(date: Date(), searchText: nil))")
    }
}
