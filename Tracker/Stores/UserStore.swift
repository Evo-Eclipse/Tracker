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
    private let statisticsKey = "StatisticsData"

    private init() {}

    var isOnboardingCompleted: Bool {
        get {
            UserDefaults.standard.bool(forKey: onboardingCompletedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: onboardingCompletedKey)
        }
    }

    func updateStatistics(completedCount: Int) {
        UserDefaults.standard.set(completedCount, forKey: statisticsKey)
    }

    func getCompletedTrackers() -> Int {
        return UserDefaults.standard.integer(forKey: statisticsKey)
    }
}
