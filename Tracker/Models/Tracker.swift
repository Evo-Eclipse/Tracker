//
//  Tracker.swift
//  Tracker
//
//  Created by Pavel Komarov on 28.07.2025.
//

import UIKit

enum Weekday: Int, CaseIterable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday

    var long: String {
        switch self {
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }

    var short: String {
        switch self {
        case .monday: return "Пн"
        case .tuesday: return "Вт"
        case .wednesday: return "Ср"
        case .thursday: return "Чт"
        case .friday: return "Пт"
        case .saturday: return "Сб"
        case .sunday: return "Вс"
        }
    }
}

struct Tracker {
    let id: UInt
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
}
