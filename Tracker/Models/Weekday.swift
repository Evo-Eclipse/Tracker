//
//  Weekday.swift
//  Tracker
//
//  Created by Pavel Komarov on 02.08.2025.
//

enum Weekday: Int, CaseIterable {
    case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday

    var long: String {
        switch self {
        case .monday: return L10n.DaysOfWeek.monday
        case .tuesday: return L10n.DaysOfWeek.tuesday
        case .wednesday: return L10n.DaysOfWeek.wednesday
        case .thursday: return L10n.DaysOfWeek.thursday
        case .friday: return L10n.DaysOfWeek.friday
        case .saturday: return L10n.DaysOfWeek.saturday
        case .sunday: return L10n.DaysOfWeek.sunday
        }
    }

    var short: String {
        switch self {
        case .monday: return L10n.DaysOfWeek.mondayShort
        case .tuesday: return L10n.DaysOfWeek.tuesdayShort
        case .wednesday: return L10n.DaysOfWeek.wednesdayShort
        case .thursday: return L10n.DaysOfWeek.thursdayShort
        case .friday: return L10n.DaysOfWeek.fridayShort
        case .saturday: return L10n.DaysOfWeek.saturdayShort
        case .sunday: return L10n.DaysOfWeek.sundayShort
        }
    }

    static func fromSystemIndex(_ index: Int) -> Weekday {
        switch index {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}
