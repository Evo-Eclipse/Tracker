//
//  AppColor+Coding.swift
//  Tracker
//
//  Created by Cascade on 10.08.2025.
//

import Foundation

public enum AppColorCodingError: Error { case decodeFailed }

public extension AppColor {
    func toData() throws -> Data {
        try JSONEncoder().encode(self)
    }

    static func fromData(_ data: Data) throws -> AppColor {
        do {
            return try JSONDecoder().decode(AppColor.self, from: data)
        } catch {
            throw AppColorCodingError.decodeFailed
        }
    }
}
