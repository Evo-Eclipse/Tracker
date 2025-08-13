//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Pavel Komarov on 24.07.2025.
//

import UIKit

final class TabBarViewController: UITabBarController {

    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        setupViewControllers()
    }

    // MARK: - Private Methods

    private func setupTabBar() {
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray

        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .ypWhite

            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        } else {
            tabBar.barTintColor = .ypWhite
            tabBar.isTranslucent = false
        }
    }

    private func setupViewControllers() {
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: L10n.Navigation.trackers,
            image: UIImage(systemName: "record.circle.fill"),  // record.circle
            selectedImage: UIImage(systemName: "record.circle.fill")
        )

        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: L10n.Navigation.statistics,
            image: UIImage(systemName: "hare.fill"),  // hare
            selectedImage: UIImage(systemName: "hare.fill")
        )

        viewControllers = [trackersNavigationController, statisticsViewController]
    }
}
