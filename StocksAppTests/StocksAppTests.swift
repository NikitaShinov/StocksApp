//
//  StocksAppTests.swift
//  StocksAppTests
//
//  Created by max on 17.01.2022.
//
@testable import StocksApp

import XCTest

class StocksAppTests: XCTestCase {
    
    func testSomething() {
        let number = 1
        let string = "1"
        XCTAssertEqual(number, Int(string))
    }
    
    func testCandleSticksDataConversion() {
        let doubles: [Double] = Array(repeating: 12.5, count: 10)
        var timeStamps: [TimeInterval] = []
        for x in 0..<10 {
            let interval = Date().addingTimeInterval(3600 * TimeInterval(x)).timeIntervalSince1970
            timeStamps.append(interval)
        }
        
        timeStamps.shuffle()
        
        let marketData = MarketDataResponse(open: doubles,
                                            close: doubles,
                                            timestamps: timeStamps)
        
        let candleSticks = marketData.candleSticks
        XCTAssertEqual(candleSticks.count, marketData.open.count)
        XCTAssertEqual(candleSticks.count, marketData.close.count)
        XCTAssertEqual(candleSticks.count, marketData.timestamps.count)
        
        //Verify sort
        let dates = candleSticks.map { $0.date }
        for x in 0..<dates.count-1 {
            let current = dates[x]
            let next = dates[x+1]
            XCTAssertTrue(current > next)
        }
    }

}
