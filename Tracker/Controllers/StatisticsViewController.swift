//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 24.07.2025.
//

import UIKit

final class StatisticsViewController: UIViewController {

    // MARK: - Private Properties

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.statisticsTab
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var statisticsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var completedTrackersCard: UIView = {
        let cardView = UIView()
        cardView.backgroundColor = .ypWhite
        cardView.layer.cornerRadius = 16
        return cardView
    }()

    private lazy var completedCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.text = "0"
        return label
    }()

    private lazy var completedDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.text = L10n.completedTrackersTitle
        return label
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
        view.image = UIImage(named: "iconSmilingFaceWithTear")
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emptyStatisticsMessage
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()

    private var recordStore: TrackerRecordStore!

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypWhite

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            recordStore = appDelegate.recordStore
            recordStore.statisticsDelegate = self
        } else {
            assertionFailure("AppDelegate unavailable")
        }

        setupNavigationBar()
        setupViews()
        setupConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupGradientBorder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = L10n.statisticsTab
    }

    private func setupViews() {
        [statisticsStackView, placeholderStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        [placeholderImageView, placeholderLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            placeholderStackView.addArrangedSubview($0)
        }

        statisticsStackView.addArrangedSubview(completedTrackersCard)

        [completedCountLabel, completedDescriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            completedTrackersCard.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statisticsStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statisticsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            completedCountLabel.topAnchor.constraint(equalTo: completedTrackersCard.topAnchor, constant: 12),
            completedCountLabel.leadingAnchor.constraint(equalTo: completedTrackersCard.leadingAnchor, constant: 12),
            completedCountLabel.trailingAnchor.constraint(equalTo: completedTrackersCard.trailingAnchor, constant: -12),

            completedDescriptionLabel.topAnchor.constraint(equalTo: completedCountLabel.bottomAnchor, constant: 8),
            completedDescriptionLabel.leadingAnchor.constraint(equalTo: completedTrackersCard.leadingAnchor, constant: 12),
            completedDescriptionLabel.trailingAnchor.constraint(equalTo: completedTrackersCard.trailingAnchor, constant: -12),
            completedDescriptionLabel.bottomAnchor.constraint(equalTo: completedTrackersCard.bottomAnchor, constant: -12),

            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func updateStatistics() {
        let completedCount = recordStore.getTotalCompletedCount()

        DispatchQueue.main.async { [weak self] in
            self?.completedCountLabel.text = "\(completedCount)"
            self?.updateUI(hasData: completedCount > 0)
        }

        UserStore.shared.updateStatistics(completedCount: completedCount)
    }

    private func setupGradientBorder() {
        completedTrackersCard.layer.sublayers?.removeAll { $0 is CAGradientLayer }

        let gradient = CAGradientLayer()
        gradient.frame = completedTrackersCard.bounds
        gradient.colors = [
            UIColor(red: 0.99, green: 0.3, blue: 0.29, alpha: 1).cgColor,  // #FD4C49
            UIColor(red: 0.27, green: 0.9, blue: 0.62, alpha: 1).cgColor,  // #46E69D
            UIColor(red: 0, green: 0.48, blue: 0.98, alpha: 1).cgColor,    // #007BFA
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16

        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.path = UIBezierPath(roundedRect: completedTrackersCard.bounds, cornerRadius: 16).cgPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        gradient.mask = shape

        completedTrackersCard.layer.insertSublayer(gradient, at: 0)
    }

    private func updateUI(hasData: Bool) {
        statisticsStackView.isHidden = !hasData
        placeholderStackView.isHidden = hasData
    }
}

// MARK: - TrackerRecordStoreStatisticsDelegate

extension StatisticsViewController: TrackerRecordStoreStatisticsDelegate {
    func recordStoreDidUpdateStatistics() {
        updateStatistics()
    }
}
