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
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()

    private var selectedDays: Set<Weekday> = []
    
    // MARK: - Override Methods
    
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
        title = "Расписание"
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

// MARK: - ScheduleCell

final class ScheduleCell: UITableViewCell {
    static let identifier = "ScheduleCell"
    
    var onSwitchToggled: ((Bool) -> Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .ypBlue
        switchControl.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        return switchControl
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
    
    @objc private func switchToggled() {
        onSwitchToggled?(switchControl.isOn)
    }
    
    private func setupCell() {
        backgroundColor = .ypBackground.withAlphaComponent(0.3)
        selectionStyle = .none
        
        [titleLabel, switchControl, separatorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func configure(title: String, isSelected: Bool, isFirstCell: Bool, isLastCell: Bool) {
        titleLabel.text = title
        switchControl.isOn = isSelected
        
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
