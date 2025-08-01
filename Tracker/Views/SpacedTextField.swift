//
//  SpacedTextField.swift
//  Tracker
//
//  Created by Pavel Komarov on 01.08.2025.
//

import UIKit

final class SpacedTextField: UITextField {
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.clearButtonRect(forBounds: bounds)
        rect.origin.x = bounds.maxX - 12 - rect.width
        return rect
    }

    private func adjustedTextRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.textRect(forBounds: bounds)
        let clearRect = super.clearButtonRect(forBounds: bounds)
        rect.size.width = clearRect.minX - 12 - rect.origin.x
        return rect
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        adjustedTextRect(forBounds: bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        adjustedTextRect(forBounds: bounds)
    }
}
