//
//  DayPluralization.swift
//  Tracker
//
//  Created by Pavel Komarov on 01.08.2025.
//

enum DayPluralization {
    static func localizedString(for count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100
        
        let text: String
        if lastTwoDigits >= 11 && lastTwoDigits <= 14 {
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
        
        return "\(count) \(text)"
    }
}
