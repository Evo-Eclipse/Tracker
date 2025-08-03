//
//  UIViewController+dismissKeyboardOnTap.swift
//  Tracker
//
//  Created by Pavel Komarov on 02.08.2025.
//

import UIKit

extension UIViewController {
    /// Adds a tap gesture to dismiss the keyboard when tapping outside of text fields.
    /// Call this in `viewDidLoad()` to enable the behavior.
    func dismissKeyboardOnTap() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
