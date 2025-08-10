//
//  AppColor.swift
//  Tracker
//
//  Created by Cascade on 10.08.2025.
//

import Foundation

/// A UIKit-free color representation for the domain layer.
public struct AppColor: Codable, Equatable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public extension AppColor {
    static let black = AppColor(red: 0, green: 0, blue: 0, alpha: 1)
}
