//
//  UserStore.swift
//  Tracker
//
//  Created by Pavel Komarov on 12.08.2025.
//

import Foundation

final class UserStore {
    static let shared = UserStore()
    
    private let onboardingCompletedKey = "IsOnboardingCompleted"
    
    private init() {}
    
    var isOnboardingCompleted: Bool {
        get {
            UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: onboardingCompletedKey)
        }
    }
}
