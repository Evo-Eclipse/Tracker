//
//  Int+LocalizedDayCount.swift
//  Tracker
//
//  Created by Pavel Komarov on 01.08.2025.
//

import Foundation

extension Int {
    /// Localized Russian string for the day count with correct plural form.
    /// - Returns: A string in the format "X день/дня/дней" where X is the number of days.
    var localizedDayCount: String {
        let lastDigit = self % 10
        let lastTwoDigits = self % 100
        
        let text: String
        if (11...14).contains(lastTwoDigits) {
            text = "дней"
        } else {
            switch lastDigit {
            case 1:
                text = "день"
            case 2, 3, 4:
                text = "дня"
            default:
                text = "дней"
            }
        }
        
        return "\(self) \(text)"
    }
}
