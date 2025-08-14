//
//  FilterCell.swift
//  Tracker
//
//  Created by Pavel Komarov on 14.08.2025.
//

import UIKit

final class FilterCell: UITableViewCell {

    // MARK: - Public Properties

    static let identifier = "FilterCell"

    // MARK: - Private Properties

    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ypGray.withAlphaComponent(0.12)
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()

    private lazy var checkmark: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = .ypBlue
        return imageView
    }()

    private let topSeparator = UIView()
    private let bottomSeparator = UIView()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func configure(title: String, isFirst: Bool, isLast: Bool, isChecked: Bool) {
        titleLabel.text = title
        checkmark.isHidden = !isChecked

        // Rounded corners per design: 16 on first top, 16 on last bottom
        var maskedCorners: CACornerMask = []
        if isFirst { maskedCorners.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner]) }
        if isLast { maskedCorners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner]) }
        bgView.layer.cornerRadius = (isFirst || isLast) ? 16 : 0
        bgView.layer.maskedCorners = maskedCorners

        // Custom separators: hide top on first, hide bottom on last
        topSeparator.isHidden = isFirst
        bottomSeparator.isHidden = isLast
    }

    // MARK: - Private Methods

    private func setupViews() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        [bgView, topSeparator, bottomSeparator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        [titleLabel, checkmark].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview($0)
        }

        topSeparator.backgroundColor = UIColor.ypGray.withAlphaComponent(0.3)
        bottomSeparator.backgroundColor = UIColor.ypGray.withAlphaComponent(0.3)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),

            checkmark.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            checkmark.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),

            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            topSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            topSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            topSeparator.topAnchor.constraint(equalTo: contentView.topAnchor),

            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            bottomSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bottomSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bottomSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
