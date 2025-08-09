//
//  Tracker.swift
//  Tracker
//
//  Created by Pavel Komarov on 28.07.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
}
