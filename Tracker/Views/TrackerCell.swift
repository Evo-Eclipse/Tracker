//
//  TrackerCell.swift
//  Tracker
//
//  Created by Pavel Komarov on 29.07.2025.
//

import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didToggleTracker(_ tracker: Tracker, on date: Date)
    func getCompletionCount(for trackerId: UInt) -> Int
    func isTrackerCompleted(_ trackerId: UInt, on date: Date) -> Bool
}

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    // MARK: - Public Properties
    
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - Private Properties
    
    private var tracker: Tracker?
    private var currentDate: Date = Date()
    private var isCompleted: Bool = false
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBlack  // Adapting
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "🌱"  // Adapting
        return label
    }()
    
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ypWhite.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.numberOfLines = 2
        label.text = "Поливать растения"  // Adapting
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.text = "0 дней"  // Adapting
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "button_complete")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .ypBlack  // Adapting
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func configure(with tracker: Tracker, on date: Date = Date()) {
        self.tracker = tracker
        self.currentDate = date
        
        cardView.backgroundColor = tracker.color
        completeButton.tintColor = tracker.color
        
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        
        updateCompletionState()
        updateCountLabel()
    }
    
    // MARK: - Actions
    
    @objc private func completeButtonTapped() {
        guard let tracker = tracker else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: currentDate)
        
        if selectedDate > today {
            return
        }
        
        delegate?.didToggleTracker(tracker, on: currentDate)
        
        isCompleted.toggle()
        updateCompletionState()
        updateCountLabel()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        [emojiBackgroundView, emojiLabel, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
        
        [cardView, countLabel, completeButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalToConstant: 44),
            completeButton.heightAnchor.constraint(equalToConstant: 44),
            
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),
            countLabel.trailingAnchor.constraint(lessThanOrEqualTo: completeButton.leadingAnchor, constant: -8)
        ])
    }
    
    private func updateCompletionState() {
        guard let tracker = tracker else { return }
        
        isCompleted = delegate?.isTrackerCompleted(tracker.id, on: currentDate) ?? false
        
        let imageName = isCompleted ? "button_completed" : "button_complete"
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        completeButton.setImage(image, for: .normal)
        
        completeButton.alpha = isCompleted ? 0.3 : 1.0
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: currentDate)
        completeButton.isEnabled = selectedDate <= today
    }
    
    private func updateCountLabel() {
        guard let tracker = tracker else { return }
        
        let completionCount = delegate?.getCompletionCount(for: tracker.id) ?? 0
        countLabel.text = completionCount.localizedDayCount
    }
}
