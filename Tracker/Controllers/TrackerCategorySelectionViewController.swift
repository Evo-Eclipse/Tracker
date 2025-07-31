//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

final class TrackerCategorySelectionViewController: UIViewController {
    
    // MARK: - Public Properties

    var onCategorySelected: ((String) -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
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
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        return tableView
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = !categories.isEmpty
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var tableViewTopConstraint: NSLayoutConstraint!
    private var errorLabelHeightConstraint: NSLayoutConstraint!

    private let maxTitleLength = 38
    private var categories: [String] = [
        "Важное",
        "Здоровье", 
        "Обучение",
        "Работа",
        "Развлечения",
        "Спорт",
        "Творчество",
        "Хобби"
    ]
    private var selectedCategory: String?
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        setupNavigationBar()
        setupViews()
        setupConstraints()
        updateEmptyState()
    }
    
    // MARK: - Actions
    
    @objc private func doneButtonTapped() {
        if let newCategoryText = titleTextField.text,
           !newCategoryText.trimmingCharacters(in: .whitespaces).isEmpty {
            let trimmedText = newCategoryText.trimmingCharacters(in: .whitespaces)
            
            if !categories.contains(trimmedText) {
                categories.append(trimmedText)
                categories.sort()
                tableView.reloadData()
                updateEmptyState()
            }
            
            onCategorySelected?(trimmedText)
            navigationController?.popViewController(animated: true)
            return
        }
        
        if let selected = selectedCategory {
            onCategorySelected?(selected)
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func textFieldDidChange() {
        let text = titleTextField.text ?? ""
        
        if text.count >= maxTitleLength {
            titleTextField.text = String(text.prefix(maxTitleLength))
            setErrorHidden(false)
        } else {
            setErrorHidden(true)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        title = "Категория"
    }
    
    private func setupViews() {
        [titleTextField, errorLabel, tableView, emptyStateLabel, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
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
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setErrorHidden(_ hidden: Bool) {
        let wasHidden = errorLabel.isHidden
        errorLabel.isHidden = hidden
        
        /// Avoid unnecessary animations on first show
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
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !categories.isEmpty
    }
}

// MARK: - UITextFieldDelegate

extension TrackerCategorySelectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource

extension TrackerCategorySelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        let isSelected = category == selectedCategory
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == categories.count - 1
        
        cell.configure(
            title: category,
            isSelected: isSelected,
            isFirstCell: isFirstCell,
            isLastCell: isLastCell
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TrackerCategorySelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        tableView.reloadData()  // Update checkmarks
    }
}

// MARK: - CategoryCell

final class CategoryCell: UITableViewCell {
    static let identifier = "CategoryCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .ypBlue
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .ypBackground.withAlphaComponent(0.3)
        selectionStyle = .none
        
        [titleLabel, checkmarkImageView, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkImageView.leadingAnchor, constant: -16),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func configure(title: String, isSelected: Bool, isFirstCell: Bool, isLastCell: Bool) {
        titleLabel.text = title
        checkmarkImageView.isHidden = !isSelected
        
        if isFirstCell && isLastCell {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirstCell {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLastCell {
            layer.cornerRadius = 16
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            layer.cornerRadius = 0
        }
        
        separatorView.isHidden = isLastCell
    }
}
