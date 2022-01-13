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
        
    }

    public var watchlist: [String] {
        return []
    }
    
    public var hasOnBoarded: Bool {
        return false
    }
    
    public func addToWatchList() {
        
    }
    
    public func removeFromWatchList() {
        
    }
}
