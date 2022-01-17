//
//  Extensions.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import Foundation
import UIKit

// MARK: - Notification

extension Notification.Name {
    // Notification for when symbol gets added to watchlist
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}

// MARK: - NumberFormatter
extension NumberFormatter {
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    // Formatter for decimal style
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
        
}

//extension UIImageView {
//    func setImage(with url: URL?) {
//        guard let url = url else { return }
//        DispatchQueue.global(qos: .userInteractive).async {
//            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
//                guard let data = data, error == nil else {
//                    return
//                }
//                DispatchQueue.main.async {
//                    self?.image = UIImage(data: data)
//                }
//            }
//            .resume()
//        }
//    }
//}


// MARK: - String
extension String {
    // Create String from time interval
    static func string(from timeinterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeinterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    // Format number to string
    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.numberFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}
// MARK: - DateFormatter

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY--MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
// MARK: - Add Subview
extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

// MARK: - Framing

extension UIView {
    
    var width: CGFloat {
        frame.size.width
    }
    
    var height: CGFloat {
        frame.size.height
    }
    
    var left: CGFloat {
        frame.origin.x
    }
    
    var right: CGFloat {
        left + width
    }
    
    var top: CGFloat {
        frame.origin.y
    }
    
    var bottom: CGFloat {
        top + height
    }
}

//MARK: - CandleStick sorting

extension Array where Element == CandleStick {
    func getchangePercentage() -> Double {
        let latestDate = self[0].date
        guard let latestClose = self.first?.close,
              let priorClose = self.first(where: {
                  !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
              })?.close else {
                  return 0
        }
        let diff = 1 - (priorClose / latestClose)
        return diff
    }
}
