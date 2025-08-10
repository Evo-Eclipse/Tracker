//
//  StoreObjectChange.swift
//  Tracker
//
//  Created by Pavel Komarov on 08.08.2025.
//

import Foundation

enum StoreObjectChange {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
    case move(from: IndexPath, to: IndexPath)
}
