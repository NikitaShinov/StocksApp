//
//  MarketDataResponse.swift
//  StocksApp
//
//  Created by max on 16.01.2022.
//

import Foundation

struct MarketDataResponse: Codable  {
    let open: [Double]
    let close: [Double]
    let timestamps: [TimeInterval]
    
    enum CodingKeys: String, CodingKey {
        case open = "o"
        case close = "c"
        case timestamps = "t"
    }
    
    var candleSticks: [CandleStick] {
        var result = [CandleStick]()
        
        for index in 0..<open.count {
            result.append(
                CandleStick(
                    date: Date(timeIntervalSince1970: timestamps[index]),
                    open: open[index],
                    close: close[index])
            )
        }
        let sortedData = result.sorted(by: {$0.date > $1.date})
        return sortedData
    }
}

struct CandleStick {
    let date: Date
//    let high: Double
//    let low: Double
    let open: Double
    let close: Double
}
