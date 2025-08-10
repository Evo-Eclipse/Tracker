//
//  UIColor+Coding.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//

import UIKit

enum ColorCodingError: Error {
    case decodeFailed
}

// NSKeyedArchiver/Unarchiver helpers to convert UIColor <-> Data
extension UIColor {
    func toData() throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
    }

    static func fromData(_ data: Data) throws -> UIColor {
        guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            throw ColorCodingError.decodeFailed
        }
        return color
    }
}
