//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Pavel Komarov on 01.08.2025.
//

import UIKit

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
        let sc = UISwitch()
        sc.onTintColor = .ypBlue
        sc.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        return sc
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
