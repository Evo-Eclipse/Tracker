//
//  DaysFormatter.swift
//  Tracker
//
//  Created by Pavel Komarov on 13.08.2025.
//

import Foundation

struct DaysFormatter {
    static func localizedDaysCount(_ count: Int) -> String {
        let format = NSLocalizedString("daysCount", comment: "Days count with pluralization")
        return String.localizedStringWithFormat(format, count)
    }
}
