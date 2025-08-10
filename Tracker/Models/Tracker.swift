//
//  Tracker.swift
//  Tracker
//
//  Created by Pavel Komarov on 28.07.2025.
//

import Foundation

struct Tracker {
    let id: UUID
    let title: String
    let color: AppColor
    let emoji: String
    let schedule: [Weekday]
}
