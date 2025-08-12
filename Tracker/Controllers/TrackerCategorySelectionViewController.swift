//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

final class TrackerCategorySelectionViewController: UIViewController {
    
    // MARK: - Public Properties

    var onCategorySelected: ((String?) -> Void)?
    
    // MARK: - Private Properties
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        return tableView
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
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let maxTitleLength = 38
    private var categories: [String] = []
    private var selectedCategory: String?
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()
        
        view.backgroundColor = .ypWhite
        
        setupNavigationBar()
        setupViews()
        setupConstraints()
        updateEmptyState()
    }
    
    // MARK: - Actions
    
    @objc private func addCategoryButtonTapped() {
        presentNewCategoryViewController()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        title = "Категория"
        navigationItem.hidesBackButton = true
    }
    
    private func presentNewCategoryViewController() {
        let newCategoryVC = TrackerNewCategoryViewController()
        newCategoryVC.onCategoryCreated = { [weak self] newCategory in
            guard let self = self else { return }
            
            if !self.categories.contains(newCategory) {
                self.categories.append(newCategory)
                self.categories.sort()
                self.tableView.reloadData()
                self.updateEmptyState()
            }
            
            self.selectedCategory = newCategory
            self.tableView.reloadData()
        }
        
        let navigationController = UINavigationController(rootViewController: newCategoryVC)
        present(navigationController, animated: true)
    }
    
    private func setupViews() {
        [tableView, placeholderStackView, addCategoryButton].forEach {
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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateEmptyState() {
        let isEmpty = categories.isEmpty
        placeholderStackView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
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
        onCategorySelected?(selectedCategory)
        navigationController?.popViewController(animated: true)
    }
}
