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
        guard let title = titleTextField.text, !title.isEmpty else { return }
        
        let category = selectedCategory ?? "По умолчанию"
        
        if trackerType.hasSchedule && selectedSchedule.isEmpty {
            return
        }
        
        let weekDays = Array(selectedSchedule)
        
        let tracker = Tracker(
            id: UInt.random(in: 1...UInt.max),
            title: title,
            color: .ypSelection1,
            emoji: "🔥",
            schedule: weekDays
        )
        
        print("Creating \(trackerType): \(title), category: \(category), days: \(selectedSchedule)")
        
        delegate?.didCreateTracker(tracker, in: category)
        
        dismiss(animated: true)
    }
    
    @objc private func textFieldDidChange() {
        let text = titleTextField.text ?? ""
        
        if text.count >= maxTitleLength {
            titleTextField.text = String(text.prefix(maxTitleLength))
            setErrorHidden(false)
        } else {
            setErrorHidden(true)
        }
        
        let hasTitle = !(titleTextField.text?.isEmpty ?? true)
        let hasScheduleIfNeeded = !trackerType.hasSchedule || !selectedSchedule.isEmpty
        
        let isValid = hasTitle && hasScheduleIfNeeded
        
        createButton.isEnabled = isValid
        createButton.backgroundColor = isValid ? .ypBlack : .ypGray
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        title = trackerType.title
        navigationItem.hidesBackButton = true
    }
    
    private func setupViews() {
        [titleTextField, errorLabel, tableView, cancelButton, createButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        let tableHeight: CGFloat = trackerType.hasSchedule ? 150 : 75
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 32)
        errorLabelHeightConstraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            errorLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            errorLabelHeightConstraint,
            
            tableViewTopConstraint,
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.widthAnchor.constraint(equalToConstant: 166),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.widthAnchor.constraint(equalToConstant: 161),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
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
                self?.textFieldDidChange()
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(categoryVC, animated: true)
        } else {
            let scheduleVC = TrackerScheduleSelectionViewController()
            scheduleVC.onScheduleSelected = { [weak self] selectedDays in
                self?.selectedSchedule = selectedDays
                self?.textFieldDidChange()
                self?.tableView.reloadData()
            }
            navigationController?.pushViewController(scheduleVC, animated: true)
        }
    }
}
