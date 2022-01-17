//
//  WatchListTableViewCell.swift
//  StocksApp
//
//  Created by max on 15.01.2022.
//

import UIKit

protocol WatchListTableViewCellDelegate: AnyObject {
    func didUpdateMaxWidth()
}

class WatchListTableViewCell: UITableViewCell {

    static let identifier = "WatchListTableViewCell"
    
    weak var delegate: WatchListTableViewCellDelegate?
    
    static let preferredHeight: CGFloat = 60
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }
    
    // SymbolLabel
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    // CompanyLabel
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    // Mini chart view
    private let minichartView: StockChartView = {
        let chart = StockChartView()
        chart.isUserInteractionEnabled = false
        chart.clipsToBounds = true
        return chart
    }()
    // Price label
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    // Change in price label
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        addSubviews(
            symbolLabel,
            companyLabel,
            minichartView,
            priceLabel,
            changeLabel
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        symbolLabel.sizeToFit()
        companyLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        let yStart: CGFloat = (contentView.height - symbolLabel.height - companyLabel.height) / 2
        symbolLabel.frame = CGRect(x: separatorInset.left,
                                   y: yStart,
                                   width: symbolLabel.width,
                                   height: symbolLabel.height)
        
        companyLabel.frame = CGRect(x: separatorInset.left,
                                    y: symbolLabel.bottom,
                                   width: companyLabel.width,
                                   height: companyLabel.height)
        
        let currentWidth = max(max(priceLabel.width, changeLabel.width), WatchListViewController.maxChangewidth)
        
        if currentWidth > WatchListViewController.maxChangewidth {
            WatchListViewController.maxChangewidth = currentWidth
            delegate?.didUpdateMaxWidth()
        }
        
        priceLabel.frame = CGRect(x: contentView.width - 10 - currentWidth,
                                  y: (contentView.height - priceLabel.height - changeLabel.height) / 2,
                                   width: currentWidth,
                                   height: priceLabel.height)
        
        changeLabel.frame = CGRect(x: contentView.width - 10 - currentWidth,
                                   y: priceLabel.bottom,
                                   width: currentWidth,
                                   height: changeLabel.height)
        
        minichartView.frame = CGRect(x: priceLabel.left - (contentView.width / 3) - 5,
                                     y: 6,
                                     width: contentView.width / 3,
                                     height: contentView.height - 12)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        companyLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        minichartView.reset()
    }
    
    public func configure(with viewModel: ViewModel){
        symbolLabel.text = viewModel.symbol
        companyLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        //chart
        minichartView.configure(with: viewModel.chartViewModel)
    }
    
}
