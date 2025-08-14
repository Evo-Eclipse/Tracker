//
//  TrackerEditViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 14.08.2025.
//

import UIKit

protocol TrackerEditViewControllerDelegate: AnyObject {
    func didUpdateTracker(_ tracker: Tracker)
}

final class TrackerEditViewController: UIViewController {

    // MARK: - Public Properties

    weak var delegate: TrackerEditViewControllerDelegate?

    // MARK: - Private Properties

    private let originalTracker: Tracker
    private var recordStore: TrackerRecordStore!

    private lazy var titleTextField: UITextField = {
        let textField = SpacedTextField()
        textField.placeholder = L10n.trackerNamePlaceholder
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .ypBackground.withAlphaComponent(0.3)
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = MessageFormatter.characterLimitTemplate(maxTitleLength)
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.cancelButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.emojiSectionTitle
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var colorsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        return collectionView
    }()

    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.colorSectionTitle
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.saveButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private var tableViewTopConstraint: NSLayoutConstraint!
    private var errorLabelHeightConstraint: NSLayoutConstraint!

    private let trackerType: TrackerType
    private let maxTitleLength = 38

    private var selectedCategory: String?
    private var selectedSchedule: Set<Weekday> = []
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    // MARK: - Initializers

    init(tracker: Tracker) {
        self.originalTracker = tracker
        self.trackerType = tracker.schedule.count == 7 ? .irregularEvent : .habit
        super.init(nibName: nil, bundle: nil)

        // Initialize with tracker data
        self.selectedEmoji = tracker.emoji
        self.selectedColor = UIColor(appColor: tracker.color)
        self.selectedSchedule = Set(tracker.schedule)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()

        view.backgroundColor = .ypWhite

        // Get record store from app delegate
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            recordStore = appDelegate.recordStore
        }

        setupNavigationBar()
        setupViews()
        setupConstraints()
        setErrorHidden(true)
        populateFields()
        updateDaysCount()
    }

    // MARK: - Actions

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text,
              !title.trimmingCharacters(in: .whitespaces).isEmpty,
              let emoji = selectedEmoji,
              let uiColor = selectedColor
        else { return }

        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let schedule = trackerType.hasSchedule ? Array(selectedSchedule) : Weekday.allCases

        let updatedTracker = Tracker(
            id: originalTracker.id, // Keep original ID
            title: trimmedTitle,
            color: uiColor.appColor,
            emoji: emoji,
            schedule: schedule
        )

        delegate?.didUpdateTracker(updatedTracker)
        dismiss(animated: true)
    }

    @objc private func textFieldDidChange() {
        if titleTextField.text?.count ?? 0 > 38 {
            titleTextField.text = String((titleTextField.text ?? "").prefix(38))
        }
        updateCreateButtonState()
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = L10n.editHabitTitle
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleTextField, errorLabel, daysCountLabel, tableView, emojiLabel, emojiCollectionView,
         colorLabel, colorsCollectionView, cancelButton, saveButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }

    private func setupConstraints() {
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 24)
        errorLabelHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            daysCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            daysCountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            titleTextField.topAnchor.constraint(equalTo: daysCountLabel.bottomAnchor, constant: 40),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            errorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            errorLabelHeightConstraint,

            tableViewTopConstraint,
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: trackerType.hasSchedule ? 150 : 75),

            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),

            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorsCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204),

            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -34),

            saveButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -34)
        ])
    }

    private func populateFields() {
        titleTextField.text = originalTracker.title

        // TODO: Get category from tracker store when category support is added to edit flow
        selectedCategory = "Важное" // Default for now
    }

    private func updateDaysCount() {
        let completionCount = recordStore?.getCompletionCount(for: originalTracker.id) ?? 0
        daysCountLabel.text = DaysFormatter.localizedDaysCount(completionCount)
    }

    private func setErrorHidden(_ hidden: Bool) {
        errorLabel.isHidden = hidden
        errorLabelHeightConstraint.constant = hidden ? 0 : 22
        tableViewTopConstraint.constant = hidden ? 24 : 46
    }

    private func updateCreateButtonState() {
        let hasTitle = !(titleTextField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        let hasCategory = selectedCategory != nil
        let hasSchedule = !trackerType.hasSchedule || !selectedSchedule.isEmpty

        let isValid = hasTitle && hasEmoji && hasColor && hasCategory && hasSchedule

        saveButton.isEnabled = isValid
        saveButton.backgroundColor = isValid ? .ypBlack : .ypGray
    }
}

// MARK: - UITextFieldDelegate

extension TrackerEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText.count > maxTitleLength {
            setErrorHidden(false)
            return false
        } else {
            setErrorHidden(true)
            return true
        }
    }
}

// MARK: - UITableViewDataSource

extension TrackerEditViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerType.hasSchedule ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .ypBackground.withAlphaComponent(0.3)
        cell.selectionStyle = .none

        // Create container view for labels
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(containerView)

        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = .ypBlack
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        subtitleLabel.textColor = .ypGray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(subtitleLabel)

        if indexPath.row == 0 {
            titleLabel.text = L10n.categoryTitle
            subtitleLabel.text = selectedCategory
        } else {
            titleLabel.text = L10n.scheduleTitle
            if selectedSchedule.isEmpty {
                subtitleLabel.text = nil
            } else if selectedSchedule.count == 7 {
                subtitleLabel.text = L10n.everyDaySchedule
            } else {
                let shortNames = selectedSchedule.sorted { $0.rawValue < $1.rawValue }.map { day in
                    day.short
                }
                subtitleLabel.text = shortNames.joined(separator: ", ")
            }
        }

        let hasSubtitle = subtitleLabel.text != nil

        // Constraints
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -40),
            containerView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15),
            containerView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -15),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])

        if hasSubtitle {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
                subtitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
            ])
        }

        // Configure cell appearance based on trackerType
        if trackerType.hasSchedule {
            if indexPath.row == 0 {
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

                let separator = UIView()
                separator.backgroundColor = .ypGray
                separator.translatesAutoresizingMaskIntoConstraints = false
                cell.contentView.addSubview(separator)

                NSLayoutConstraint.activate([
                    separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    separator.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                    separator.heightAnchor.constraint(equalToConstant: 0.5)
                ])
            } else {
                cell.layer.cornerRadius = 16
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        } else {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackerEditViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let categoryStore = appDelegate.categoryStore

            let viewModel = TrackerCategorySelectionViewModel(categoryStore: categoryStore)
            let categoryVC = TrackerCategorySelectionViewController(viewModel: viewModel)

            categoryVC.onCategorySelected = { [weak self] selectedCategory in
                self?.selectedCategory = selectedCategory
                self?.updateCreateButtonState()
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(categoryVC, animated: true)
        } else {
            let scheduleVC = TrackerScheduleSelectionViewController()
            scheduleVC.onScheduleSelected = { [weak self] selectedDays in
                self?.selectedSchedule = selectedDays
                self?.updateCreateButtonState()
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TrackerEditViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? String.selectionEmojis.count : UIColor.selectionColors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            let emoji = String.selectionEmojis[indexPath.item]
            cell.emojiLabel.text = emoji
            cell.contentView.backgroundColor = .clear
            cell.layer.cornerRadius = 16

            // Set initial selection state
            if emoji == selectedEmoji {
                cell.setSelected(true)
            } else {
                cell.setSelected(false)
            }

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = UIColor.selectionColors[indexPath.item]
            cell.configure(with: color)
            cell.layer.cornerRadius = 8

            // Set initial selection state
            if color == selectedColor {
                cell.contentView.layer.borderWidth = 3
                cell.contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
                cell.contentView.layer.cornerRadius = 8
            } else {
                cell.contentView.layer.borderWidth = 0
            }

            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerEditViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UICollectionViewDelegate

extension TrackerEditViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            // Deselect previous emoji
            if let previousEmoji = selectedEmoji,
               let previousIndex = String.selectionEmojis.firstIndex(of: previousEmoji),
               let previousCell = collectionView.cellForItem(at: IndexPath(item: previousIndex, section: 0)) as? EmojiCollectionViewCell {
                previousCell.setSelected(false)
            }

            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.setSelected(true)
                selectedEmoji = String.selectionEmojis[indexPath.item]
            }
        } else {
            // Deselect previous color
            if let previousColor = selectedColor,
               let previousIndex = UIColor.selectionColors.firstIndex(of: previousColor),
               let previousCell = collectionView.cellForItem(at: IndexPath(item: previousIndex, section: 0)) as? ColorCollectionViewCell {
                previousCell.contentView.layer.borderWidth = 0
            }

            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                cell.contentView.layer.borderWidth = 3
                cell.contentView.layer.borderColor = UIColor.selectionColors[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.contentView.layer.cornerRadius = 8
                selectedColor = UIColor.selectionColors[indexPath.item]
            }
        }
        updateCreateButtonState()
    }
}
