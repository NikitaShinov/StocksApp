//
//  PersistenceManager.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import Foundation

final class PersistanceManager {

    private init() {}
    
    static let shared = PersistanceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"
    }

    // MARK: - Public
    public var watchlist: [String] {
        if !hasOnBoarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    public func addToWatchList() {
        
    }
    
    public func removeFromWatchList() {
        
    }
    // MARK: - Private
    private var hasOnBoarded: Bool {
        return userDefaults.bool(forKey: Constants.onboardedKey)
    }

    private func setUpDefaults() {
        let map: [String: String] = [
            "AAPL": "Apple Inc",
            "MSFT": "Microsoft Corporation",
            "GOOG": "Alphabet Inc",
            "SNAP": "Snap Inc",
            "AMZN": "Amazon.com, Inc",
            "FB": "Facebook Inc",
            "WORK": "Slack Technologies",
            "NVDA": "Nvidia Inc",
            "NKE": "Nike Inc",
            "PINS": "Pinterest Inc"
        ]
        
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
