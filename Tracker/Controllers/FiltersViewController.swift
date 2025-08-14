//
//  FiltersViewController.swift
//  Tracker
//
//  Created by GitHub Copilot on 14.08.2025.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func filtersViewController(_ vc: FiltersViewController, didSelect filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {

    // MARK: - Public Properties

    weak var delegate: FiltersViewControllerDelegate?

    // MARK: - Private Properties

    private var selectedFilter: TrackerFilter

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        return tableView
    }()

    // MARK: - Initializers

    init(selected: TrackerFilter) {
        self.selectedFilter = selected
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite

        setupNavigationBar()
        setupViews()
        setupConstraints()
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = L10n.filtersTitle
        navigationItem.hidesBackButton = true
    }

    private func setupViews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TrackerFilter.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FilterCell.identifier,
            for: indexPath
        ) as? FilterCell else {
            return UITableViewCell()
        }

        let filter = TrackerFilter.allCases[indexPath.row]
        let title = title(for: filter)
        let isSelected = (filter == selectedFilter)
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == TrackerFilter.allCases.count - 1

        cell.configure(
            title: title,
            isFirst: isFirstCell,
            isLast: isLastCell,
            isChecked: isSelected
        )

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = TrackerFilter.allCases[indexPath.row]
        selectedFilter = filter
        tableView.reloadData()
        delegate?.filtersViewController(self, didSelect: filter)
        dismiss(animated: true)
    }

    // MARK: - Private Methods

    private func title(for filter: TrackerFilter) -> String {
        switch filter {
        case .all: return L10n.allTrackersFilter
        case .today: return L10n.todayTrackersFilter
        case .completed: return L10n.completedTrackersFilter
        case .incomplete: return L10n.incompleteTrackersFilter
        }
    }
}
