//
//  TrackerStore.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//

import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChange(sectionChanges: [StoreSectionChange], objectChanges: [StoreObjectChange])
}

final class TrackerStore: NSObject {

    // MARK: - Public Properties

    weak var delegate: TrackerStoreDelegate?

    // MARK: - Private Properties

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        // Sort by category title then tracker title for stable grouping
        let sortCategory = NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        let sortTitle = NSSortDescriptor(key: #keyPath(TrackerCoreData.title), ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
        request.sortDescriptors = [sortCategory, sortTitle]
        let frc = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
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

    func createTracker(_ tracker: Tracker, in categoryTitle: String) {
        container.performBackgroundTask { ctx in
            // Find or create category
            let cat = self.fetchOrCreateCategory(with: categoryTitle, in: ctx)

            // Create tracker
            let obj = TrackerCoreData(context: ctx)
            obj.id = tracker.id
            obj.title = tracker.title
            obj.emoji = tracker.emoji
            obj.category = cat
            do { obj.color = try tracker.color.toData() } catch { obj.color = Data() }
            do { obj.schedule = try tracker.schedule.toData() } catch { obj.schedule = Data() }

            do { try ctx.save() } catch { print("[TrackerStore] create error: \(error)") }
        }
    }

    func deleteTracker(trackerId: UUID) {
        container.performBackgroundTask { ctx in
            guard let obj = self.fetchTracker(by: trackerId, in: ctx) else { return }
            ctx.delete(obj)
            do { try ctx.save() } catch { print("[TrackerStore] delete error: \(error)") }
        }
    }

    func updateTracker(_ tracker: Tracker) {
        container.performBackgroundTask { ctx in
            guard let obj = self.fetchTracker(by: tracker.id, in: ctx) else { return }
            obj.title = tracker.title
            obj.emoji = tracker.emoji
            do { obj.color = try tracker.color.toData() } catch {}
            do { obj.schedule = try tracker.schedule.toData() } catch {}
            do { try ctx.save() } catch { print("[TrackerStore] update error: \(error)") }
        }
    }

    // MARK: - Read helpers for UI (no CoreData leakage)

    func numberOfSections() -> Int { fetchedResultsController.sections?.count ?? 0 }
    func numberOfItems(in section: Int) -> Int { fetchedResultsController.sections?[section].numberOfObjects ?? 0 }
    func titleForSection(_ section: Int) -> String { fetchedResultsController.sections?[section].name ?? "" }

    func tracker(at indexPath: IndexPath) -> Tracker {
        let obj = fetchedResultsController.object(at: indexPath)
        return mapToDomain(obj)
    }

    // Build a filtered snapshot grouped by category title for UI consumption
    func snapshotFiltered(date: Date, searchText: String?, filter: TrackerFilter? = nil, recordStore: TrackerRecordStore? = nil) -> [TrackerCategory] {
        var result: [TrackerCategory] = []

        let sectionsCount = numberOfSections()
        for section in 0..<sectionsCount {
            let title = titleForSection(section)
            var trackers: [Tracker] = []
            let items = numberOfItems(in: section)
            for row in 0..<items {
                let t = tracker(at: IndexPath(item: row, section: section))

                if shouldIncludeTracker(t, date: date, searchText: searchText, filter: filter, recordStore: recordStore) {
                    trackers.append(t)
                }
            }
            if !trackers.isEmpty {
                result.append(TrackerCategory(title: title, trackers: trackers))
            }
        }
        return result
    }

    // Check if there are any trackers on date (without completed/incomplete filter)
    func hasTrackersOnDate(_ date: Date, searchText: String?) -> Bool {
        let sectionsCount = numberOfSections()
        for section in 0..<sectionsCount {
            let items = numberOfItems(in: section)
            for row in 0..<items {
                let t = tracker(at: IndexPath(item: row, section: section))

                // Check without completion filter - pass nil for filter and recordStore
                if shouldIncludeTracker(t, date: date, searchText: searchText, filter: nil as TrackerFilter?, recordStore: nil as TrackerRecordStore?) {
                    return true
                }
            }
        }
        return false
    }

    // MARK: - Private Methods

    // Common logic for filtering trackers by date, search text, and completion status
    private func shouldIncludeTracker(_ tracker: Tracker, date: Date, searchText: String?, filter: TrackerFilter?, recordStore: TrackerRecordStore?) -> Bool {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        let weekday = Weekday.fromSystemIndex(weekdayIndex)

        // Prepare case-insensitive search if provided
        let query = (searchText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        let hasQuery = !query.isEmpty

        // Filter by weekday schedule (empty schedule means every day)
        let matchesDay = tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
        // For "All trackers" we ignore schedule restriction
        if !(filter == .all) {
            if !matchesDay { return false }
        }

        // Filter by search query
        if hasQuery, tracker.title.localizedStandardRange(of: query) == nil { return false }

        // Filter by completion state if requested
        if let filter = filter, let rs = recordStore {
            switch filter {
            case .all:
                break
            case .today:
                // Already constrained by date via weekday; include all
                break
            case .completed:
                if !rs.isCompleted(trackerId: tracker.id, on: date) { return false }
            case .incomplete:
                if rs.isCompleted(trackerId: tracker.id, on: date) { return false }
            }
        }

        return true
    }

    private func fetchOrCreateCategory(with title: String, in ctx: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let req: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "%K ==[cd] %@", #keyPath(TrackerCategoryCoreData.title), title)
        if let found = try? ctx.fetch(req).first { return found }
        let cat = TrackerCategoryCoreData(context: ctx)
        cat.title = title
        return cat
    }

    private func fetchTracker(by trackerId: UUID, in ctx: NSManagedObjectContext) -> TrackerCoreData? {
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "%K == %@", "id", trackerId as CVarArg)
        return try? ctx.fetch(req).first
    }

    private func mapToDomain(_ obj: TrackerCoreData) -> Tracker {
        let color: AppColor = {
            if let data = obj.color, let c = try? AppColor.fromData(data) { return c }
            return .black
        }()
        let schedule: [Weekday] = {
            if let data = obj.schedule, let s = try? [Weekday].fromData(data) { return s }
            return []
        }()
        return Tracker(id: obj.id ?? UUID(), title: obj.title ?? "", color: color, emoji: obj.emoji ?? "", schedule: schedule)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
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
        delegate?.trackerStoreDidChange(sectionChanges: sectionChanges, objectChanges: objectChanges)
        sectionChanges.removeAll(); objectChanges.removeAll()
    }
}
