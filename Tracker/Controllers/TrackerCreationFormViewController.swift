//
//  TrackerCreationFormViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

protocol TrackerCreationFormViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, in category: String)
}

final class TrackerCreationFormViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: TrackerCreationFormViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private lazy var titleTextField: UITextField = {
        let textField = SpacedTextField()
        textField.placeholder = "Введите название трекера"
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
        label.text = "Ограничение \(maxTitleLength) символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.isHidden = true
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
        button.setTitle("Отменить", for: .normal)
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
        label.text = "Emoji"
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
        label.text = "Цвет"
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
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
    
    // MARK: - Init
    
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()

        view.backgroundColor = .ypWhite
        
        setupViews()
        setupConstraints()
        setupNavigationBar()
        setErrorHidden(true)
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty,
              let emoji = selectedEmoji,
              let uiColor = selectedColor
        else { return }

        let category = selectedCategory ?? "По умолчанию"
        let schedule = trackerType.hasSchedule ? Array(selectedSchedule) : Weekday.allCases

        let newTracker = Tracker(
            id: UUID(),
            title: title,
            color: uiColor.appColor,
            emoji: emoji,
            schedule: schedule
        )

        delegate?.didCreateTracker(newTracker, in: category)
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        if titleTextField.text?.count ?? 0 > 38 {
            titleTextField.text = String((titleTextField.text ?? "").prefix(38))
            setErrorHidden(false)
        } else {
            setErrorHidden(true)
        }
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        title = trackerType.title
        navigationItem.hidesBackButton = true
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleTextField, errorLabel, tableView, emojiLabel, emojiCollectionView, colorLabel, colorsCollectionView, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let tableHeight: CGFloat = trackerType.hasSchedule ? 150 : 75
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 32)
        errorLabelHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabelHeightConstraint,
            
            tableViewTopConstraint,
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),

            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 24),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),

            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),

            colorsCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 24),
            colorsCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorsCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorsCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            cancelButton.topAnchor.constraint(equalTo: colorsCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateCreateButtonState() {
        let isTitleValid = !(titleTextField.text?.isEmpty ?? true)
        let isScheduleSelected = trackerType.hasSchedule ? !selectedSchedule.isEmpty : true
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        
        createButton.isEnabled = isTitleValid && isScheduleSelected && isEmojiSelected && isColorSelected
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .ypGray
    }
    
    private func setErrorHidden(_ hidden: Bool) {
        let wasHidden = errorLabel.isHidden
        errorLabel.isHidden = hidden
        
        if wasHidden == hidden {
            return
        }
        
        if hidden {
            errorLabelHeightConstraint.constant = 0
            tableViewTopConstraint.constant = 32
        } else {
            errorLabelHeightConstraint.constant = 22
            tableViewTopConstraint.constant = 54
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension TrackerCreationFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource

extension TrackerCreationFormViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackerType.hasSchedule ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        cell.backgroundColor = UIColor.ypBackground.withAlphaComponent(0.3)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
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
            titleLabel.text = "Категория"
            subtitleLabel.text = selectedCategory
        } else {
            titleLabel.text = "Расписание"
            if selectedSchedule.isEmpty {
                subtitleLabel.text = nil
            } else if selectedSchedule.count == 7 {
                subtitleLabel.text = "Каждый день"
            } else {
                let shortNames = selectedSchedule.sorted { $0.rawValue < $1.rawValue }.map { day in
                    day.short
                }
                subtitleLabel.text = shortNames.joined(separator: ", ")
            }
        }
        
        let hasSubtitle = subtitleLabel.text != nil
        
        // Constraints: if hasSubtitle, then subtitleLabel is below titleLabel, otherwise titleLabel is centered
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
        
        // If hasSchedule, then first cell has rounded top corners and separator, second cell has rounded bottom corners, otherwise all corners are rounded
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

// MARK: - UICollectionViewDataSource

extension TrackerCreationFormViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == emojiCollectionView ? String.selectionEmojis.count : UIColor.selectionColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.emojiLabel.text = String.selectionEmojis[indexPath.item]
            cell.contentView.backgroundColor = .clear
            cell.layer.cornerRadius = 16
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: UIColor.selectionColors[indexPath.item])
            cell.layer.cornerRadius = 8
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackerCreationFormViewController: UICollectionViewDelegateFlowLayout {
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

extension TrackerCreationFormViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.cardView.backgroundColor = .ypLightGray
                selectedEmoji = String.selectionEmojis[indexPath.item]
            }
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                cell.contentView.layer.borderWidth = 3
                cell.contentView.layer.borderColor = UIColor.selectionColors[indexPath.item].withAlphaComponent(0.3).cgColor
                cell.contentView.layer.cornerRadius = 8
                selectedColor = UIColor.selectionColors[indexPath.item]
            }
        }
        updateCreateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
                cell.cardView.backgroundColor = .clear
            }
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell {
                cell.contentView.layer.borderWidth = 0
            }
        }
    }
}

// MARK: - UITableViewDelegate

extension TrackerCreationFormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let categoryVC = TrackerCategorySelectionViewController()
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
