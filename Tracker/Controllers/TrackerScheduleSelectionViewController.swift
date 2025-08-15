//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

final class TrackerScheduleSelectionViewController: UIViewController {

    // MARK: - Public Properties

    var onScheduleSelected: ((Set<Weekday>) -> Void)?

    // MARK: - Private Properties

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.doneButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    private var selectedDays: Set<Weekday> = []

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite

        setupNavigationBar()
        setupViews()
        setupConstraints()
    }

    // MARK: - Actions

    @objc private func doneButtonTapped() {
        onScheduleSelected?(selectedDays)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = L10n.scheduleTitle
        navigationItem.hidesBackButton = true
    }

    private func setupViews() {
        [tableView, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITableViewDataSource

extension TrackerScheduleSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.identifier,
            for: indexPath
        ) as? ScheduleCell else {
            return UITableViewCell()
        }

        let weekDay = Weekday.allCases[indexPath.row]
        let isSelected = selectedDays.contains(weekDay)
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == Weekday.allCases.count - 1

        cell.configure(
            title: weekDay.long,
            isSelected: isSelected,
            isFirstCell: isFirstCell,
            isLastCell: isLastCell
        )

        cell.onSwitchToggled = { [weak self] isOn in
            if isOn {
                self?.selectedDays.insert(weekDay)
            } else {
                self?.selectedDays.remove(weekDay)
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackerScheduleSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
