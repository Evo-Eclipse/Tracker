//
//  Weekday+Coding.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//

import Foundation

//  JSON helpers to convert [Weekday] <-> Data
extension Array where Element == Weekday {
    func toData() throws -> Data {
        let raw = self.map { $0.rawValue }
        return try JSONEncoder().encode(raw)
    }

    static func fromData(_ data: Data) throws -> [Weekday] {
        let raw = try JSONDecoder().decode([Int].self, from: data)
        return raw.compactMap { Weekday(rawValue: $0) }
    }
}
