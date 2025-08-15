//
//  TrackerNewCategoryViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 12.08.2025.
//

import UIKit

final class TrackerNewCategoryViewController: UIViewController {

    // MARK: - Public Properties

    var onCategoryCreated: ((String) -> Void)?

    // MARK: - Private Properties

    private lazy var titleTextField: UITextField = {
        let textField = SpacedTextField()
        textField.placeholder = L10n.categoryNamePlaceholder
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

    private lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.characterLimitMessage
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypRed
        label.isHidden = true
        return label
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.doneButton, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    private let maxTitleLength = 38

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboardOnTap()

        view.backgroundColor = .ypWhite

        setupNavigationBar()
        setupViews()
        setupConstraints()
    }

    // MARK: - Actions

    @objc private func doneButtonTapped() {
        if let newCategoryText = titleTextField.text,
           !newCategoryText.trimmingCharacters(in: .whitespaces).isEmpty {
            let trimmedText = newCategoryText.trimmingCharacters(in: .whitespaces)
            onCategoryCreated?(trimmedText)
            dismiss(animated: true)
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty {
            doneButton.isEnabled = true
            doneButton.backgroundColor = .ypBlack
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = .ypGray
        }

        if let text = textField.text, text.count > maxTitleLength {
            textField.text = String(text.prefix(maxTitleLength))
        }
    }

    // MARK: - Private Methods

    private func setupNavigationBar() {
        title = L10n.newCategoryTitle
    }

    private func setupViews() {
        [titleTextField, warningLabel, doneButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            warningLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITextFieldDelegate

extension TrackerNewCategoryViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        if updatedText.count > 38 {
            warningLabel.isHidden = false
        } else {
            warningLabel.isHidden = true
        }

        return updatedText.count <= 38
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
