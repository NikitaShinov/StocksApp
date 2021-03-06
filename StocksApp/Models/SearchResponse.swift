//
//  SearchResponse.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import Foundation

struct SearchResponse: Codable {
    let result: [SearchResult]
}
struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}
