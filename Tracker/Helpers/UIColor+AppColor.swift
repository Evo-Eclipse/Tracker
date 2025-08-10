//
//  UIColor+AppColor.swift
//  Tracker
//
//  Created by Cascade on 10.08.2025.
//

import UIKit

public extension UIColor {
    convenience init(appColor: AppColor) {
        self.init(
            red: CGFloat(appColor.red),
            green: CGFloat(appColor.green),
            blue: CGFloat(appColor.blue),
            alpha: CGFloat(appColor.alpha)
        )
    }

    var appColor: AppColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return AppColor(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
        }
        // Fallback using white/alpha if needed
        var white: CGFloat = 0
        if getWhite(&white, alpha: &a) {
            return AppColor(red: Double(white), green: Double(white), blue: Double(white), alpha: Double(a))
        }
        return .black
    }
}
