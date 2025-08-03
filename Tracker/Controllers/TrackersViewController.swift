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
        button.setImage(UIImage(named: "button_add"), for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Поиск"
        bar.searchBarStyle = .minimal
        bar.delegate = self
        return bar
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
        view.image = UIImage(named: "icon_dizzy")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
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
    
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()

    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []

    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavigationBar()
        setupViews()
        setupConstraints()
        setupDefaultCategory()
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        presentModalViewController()
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filterVisibleTrackers()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        let addBarButtonItem = UIBarButtonItem(customView: addButton)
        navigationItem.leftBarButtonItem = addBarButtonItem
        
        let datePickerBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerBarButtonItem
    }
    
    private func setupViews() {
        [titleLabel, searchBar, placeholderStackView, collectionView].forEach {
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
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupDefaultCategory() {
        let defaultCategory = TrackerCategory(title: "По умолчанию", trackers: [])
        categories.append(defaultCategory)
    }
    
    private func presentModalViewController() {
        let modalViewController = TrackerTypeSelectionViewController()
        modalViewController.trackerDelegate = self
        let navigationController = UINavigationController(rootViewController: modalViewController)
        present(navigationController, animated: true)
    }

    private func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        if let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
            var updatedCategory = categories[categoryIndex]
            var updatedTrackers = updatedCategory.trackers
            updatedTrackers.append(tracker)
            updatedCategory = TrackerCategory(title: updatedCategory.title, trackers: updatedTrackers)
            categories[categoryIndex] = updatedCategory
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories.append(newCategory)
        }
        
        filterVisibleTrackers()
    }
    
    private func removeTracker(at indexPath: IndexPath) {
        var categoryTrackers = categories[indexPath.section].trackers
        categoryTrackers.remove(at: indexPath.item)
        
        if categoryTrackers.isEmpty {
            categories.remove(at: indexPath.section)
        } else {
            let updatedCategory = TrackerCategory(
                title: categories[indexPath.section].title,
                trackers: categoryTrackers
            )
            categories[indexPath.section] = updatedCategory
        }
        
        updateUI()
    }
    
    private func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
            self?.updatePlaceholderVisibility()
        }
    }
    
    private func updatePlaceholderVisibility() {
        let hasTrackers = !categories.isEmpty && categories.contains { !$0.trackers.isEmpty }
        
        placeholderStackView.isHidden = hasTrackers
    }

    private func filterVisibleTrackers() {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: currentDate)
        let weekday = Weekday.fromSystemIndex(weekdayIndex)

        visibleCategories = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekday) || tracker.schedule.isEmpty
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }

        updateUI()
    }
    
    // MARK: - Compositional Layout
    
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

// MARK: - UISearchBarDelegate

extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // TODO: Handle search text change
        print("Search text: \(searchText)")
    }
    
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
        
        let categoryTitle = categories[indexPath.section].title
        header.configure(with: categoryTitle)
        
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tracker = categories[indexPath.section].trackers[indexPath.item]
        print("Selected tracker: \(tracker.title)")
    }
}

// MARK: - NewTrackerViewControllerDelegate

extension TrackersViewController: TrackerCreationFormViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker, in category: String) {
        addTracker(tracker, to: category)
    }
}

// MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    func didToggleTracker(_ tracker: Tracker, on date: Date) {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        if let existingRecordIndex = completedTrackers.firstIndex(where: { 
            $0.trackerId == tracker.id && calendar.isDate($0.date, inSameDayAs: normalizedDate)
        }) {
            completedTrackers.remove(at: existingRecordIndex)
        } else {
            let record = TrackerRecord(trackerId: tracker.id, date: normalizedDate)
            completedTrackers.append(record)
        }
        
        collectionView.reloadData()
    }
    
    func getCompletionCount(for trackerId: UInt) -> Int {
        return completedTrackers.filter { $0.trackerId == trackerId }.count
    }
    
    func isTrackerCompleted(_ trackerId: UInt, on date: Date) -> Bool {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        return completedTrackers.contains { record in
            record.trackerId == trackerId && calendar.isDate(record.date, inSameDayAs: normalizedDate)
        }
    }
}
