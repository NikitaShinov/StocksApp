//
//  SearchResultTableViewCell.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("not using storyboards")
    }

}
