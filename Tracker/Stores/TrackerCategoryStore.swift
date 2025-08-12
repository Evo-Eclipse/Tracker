//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//

import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func categoryStoreDidChange(sectionChanges: [StoreSectionChange], objectChanges: [StoreObjectChange])
}

final class TrackerCategoryStore: NSObject {

    // MARK: - Public Properties

    weak var delegate: TrackerCategoryStoreDelegate?

    // MARK: - Private Properties

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.title), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        return frc
    }()

    private var sectionChanges: [StoreSectionChange] = []
    private var objectChanges: [StoreObjectChange] = []

    // MARK: - Initializers

    init(container: NSPersistentContainer) {
        self.container = container
        self.context = container.viewContext
        super.init()
        try? fetchedResultsController.performFetch()
    }

    // MARK: - Public Methods

    func createCategory(title: String) {
        container.performBackgroundTask { ctx in
            if let _ = self.fetchCategory(title: title, in: ctx) { return }  // If category exists, do nothing
            let cat = TrackerCategoryCoreData(context: ctx)
            cat.title = title
            do { try ctx.save() } catch { print("[CategoryStore] save error: \(error)") }
        }
    }

    func deleteCategory(title: String) {
        container.performBackgroundTask { ctx in
            guard let cat = self.fetchCategory(title: title, in: ctx) else { return }
            ctx.delete(cat)
            do { try ctx.save() } catch { print("[CategoryStore] delete error: \(error)") }
        }
    }

    func getAllCategories() -> [TrackerCategoryCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }

    // MARK: - Private Methods

    private func fetchCategory(title: String, in ctx: NSManagedObjectContext) -> TrackerCategoryCoreData? {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "%K ==[cd] %@", #keyPath(TrackerCategoryCoreData.title), title)
        return try? ctx.fetch(req).first
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sectionChanges.removeAll(); objectChanges.removeAll()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: sectionChanges.append(.insert(sectionIndex))
        case .delete: sectionChanges.append(.delete(sectionIndex))
        default: break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let new = newIndexPath { objectChanges.append(.insert(new)) }
        case .delete:
            if let old = indexPath { objectChanges.append(.delete(old)) }
        case .update:
            if let idx = indexPath { objectChanges.append(.update(idx)) }
        case .move:
            if let old = indexPath, let new = newIndexPath { objectChanges.append(.move(from: old, to: new)) }
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.categoryStoreDidChange(sectionChanges: sectionChanges, objectChanges: objectChanges)
        sectionChanges.removeAll(); objectChanges.removeAll()
    }
}
