//
//  Tracker.swift
//  Tracker
//
//  Created by Pavel Komarov on 28.07.2025.
//

import UIKit

enum WeekDay: Int, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

struct Tracker {
    let id: UInt
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}
