//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

final class TrackerTypeSelectionViewController: UIViewController {

    // MARK: - Public Properties

    weak var trackerDelegate: TrackerCreationFormViewControllerDelegate?

    // MARK: - Private Properties

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.habitType, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.irregularEventType, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite

        setupNavigationBar()
        setupViews()
        setupConstraints()
    }

    // MARK: - Actions

    @objc private func habitButtonTapped() {
        let newTrackerVC = TrackerCreationFormViewController(trackerType: .habit)
        newTrackerVC.delegate = trackerDelegate
        navigationController?.pushViewController(newTrackerVC, animated: true)
    }

    @objc private func irregularEventButtonTapped() {
        let newTrackerVC = TrackerCreationFormViewController(trackerType: .irregularEvent)
        newTrackerVC.delegate = trackerDelegate
        navigationController?.pushViewController(newTrackerVC, animated: true)
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = L10n.trackerCreationTitle
        navigationItem.hidesBackButton = true
    }

    private func setupViews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        [habitButton, irregularEventButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),

            habitButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
