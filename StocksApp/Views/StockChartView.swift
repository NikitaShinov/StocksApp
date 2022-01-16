//
//  StockChartView.swift
//  StocksApp
//
//  Created by max on 15.01.2022.
//

import UIKit

class StockChartView: UIView {
    
    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    //reset chartview
    func reset() {
        
    }
    
    func configure(with: ViewModel) {
        
    }
}
