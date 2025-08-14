//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 24.07.2025.
//

import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Private Properties

    private lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.buttonAdd, for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.trackersTab
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var filtersButton: UIButton = {
    let button = UIButton(type: .system)
    var config = UIButton.Configuration.filled()
    config.title = L10n.filtersButton
    config.baseBackgroundColor = .ypBlue
    config.baseForegroundColor = .ypWhite
    config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
    config.background.cornerRadius = 16
    button.configuration = config
    button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.obscuresBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        controller.searchBar.placeholder = L10n.searchPlaceholder
        return controller
    }()

    private lazy var placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.iconDizzy
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emptyTrackersMessage
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCompositionalLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackerHeaderView.identifier)
        return collectionView
    }()

    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }()

    private var trackerStore: TrackerStore!
    private var categoryStore: TrackerCategoryStore!
    private var recordStore: TrackerRecordStore!

    private var currentDate: Date = Date()
    private var visibleCategories: [TrackerCategory] = []
    private var currentFilter: TrackerFilter = .all

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            trackerStore = appDelegate.trackerStore
            categoryStore = appDelegate.categoryStore
            recordStore = appDelegate.recordStore
        } else {
            assertionFailure("AppDelegate unavailable")
        }
        trackerStore.delegate = self

        setupNavigationBar()
        setupViews()
        setupConstraints()
        filterVisibleTrackers()
    }

    // MARK: - Actions

    @objc private func addButtonTapped() {
        presentModalViewController()
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filterVisibleTrackers()
    }

    @objc private func filtersButtonTapped() {
        let filtersViewController = FiltersViewController(selected: currentFilter)
        filtersViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: filtersViewController)
        present(navigationController, animated: true)
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = L10n.trackersTab

        let addBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = addBarButtonItem

        let datePickerBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButtonItem

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupViews() {
    [placeholderStackView, collectionView, filtersButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [placeholderImageView, placeholderLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            placeholderStackView.addArrangedSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    private func presentModalViewController() {
        let modalViewController = TrackerTypeSelectionViewController()
        modalViewController.trackerDelegate = self
        let navigationController = UINavigationController(rootViewController: modalViewController)
        present(navigationController, animated: true)
    }

    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.updatePlaceholderVisibility()
        }
    }

    private func updatePlaceholderVisibility() {
        let hasTrackers = visibleCategories.contains { !$0.trackers.isEmpty }

        guard !hasTrackers else {
            placeholderStackView.isHidden = true
            return
        }

        let searchText = (searchController.searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let isSearching = !searchText.isEmpty

        configurePlaceholder(isSearching: isSearching)
        placeholderStackView.isHidden = false
    }

    private func configurePlaceholder(isSearching: Bool) {
        if isSearching {
            placeholderImageView.image = UIImage.iconFaceWithMonocle
            placeholderLabel.text = L10n.noSearchResultsMessage
        } else {
            placeholderImageView.image = UIImage.iconDizzy
            placeholderLabel.text = L10n.emptyTrackersMessage
        }
    }

    private func filterVisibleTrackers() {
        visibleCategories = trackerStore.snapshotFiltered(
            date: currentDate,
            searchText: searchController.searchBar.text,
            filter: currentFilter,
            recordStore: recordStore
        )
        updateUI()
    }

    private func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
            return self?.createTrackerSection()
        }
    }

    private func createTrackerSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(158)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 4,
            bottom: 0,
            trailing: 4
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(158)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )

        let section = NSCollectionLayoutSection(group: group)
        // section.interGroupSpacing = 0
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 0,
            bottom: 16,
            trailing: 0
        )

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(38)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        section.boundarySupplementaryItems = [header]

        return section
    }
}

// MARK: - UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterVisibleTrackers()
    }
}

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as! TrackerCell
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        cell.configure(with: tracker, on: currentDate)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerHeaderView.identifier,
            for: indexPath
        ) as! TrackerHeaderView

        let categoryTitle = visibleCategories[indexPath.section].title
        header.configure(with: categoryTitle)

        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        print("Selected tracker: \(tracker.title)")
    }
}

// MARK: - NewTrackerViewControllerDelegate

extension TrackersViewController: TrackerCreationFormViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, in category: String) {
        trackerStore.createTracker(tracker, in: category)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func didToggleTracker(_ tracker: Tracker, on date: Date) {
        recordStore.toggle(trackerId: tracker.id, on: date)
        collectionView.reloadData()
    }

    func getCompletionCount(for trackerId: UUID) -> Int {
        return recordStore.getCompletionCount(for: trackerId)
    }

    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        return recordStore.isCompleted(trackerId: trackerId, on: date)
    }
}

// MARK: - TrackerStoreDelegate

extension TrackersViewController: TrackerStoreDelegate {
    func trackerStoreDidChange(sectionChanges: [StoreSectionChange], objectChanges: [StoreObjectChange]) {
        filterVisibleTrackers()
    }
}

// MARK: - FiltersViewControllerDelegate

extension TrackersViewController: FiltersViewControllerDelegate {
    func filtersViewController(_ vc: FiltersViewController, didSelect filter: TrackerFilter) {
        currentFilter = filter
        filterVisibleTrackers()
    }
}
