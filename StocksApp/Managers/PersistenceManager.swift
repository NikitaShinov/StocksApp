//
//  PersistenceManager.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import Foundation


final class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Constants {
        
    }
    
    private init () {}
    
    public var watchList: [String] {
        return []
    }
    
    public func addToWatchList() {
        
    }
    
    public func removeFromWatchList() {
        
    }
    
    private var hasOnboarded: Bool {
        return false
    }
}
