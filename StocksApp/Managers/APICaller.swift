//
//  APICaller.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    //step 1 go to finnhubio for an account, obtain keys and base URL starting points
    private struct Constants {
        static let key = "c7bvkfqad3ia366g4tq0"//c6s97daad3ie4g2fd9ig - c7bvkfqad3ia366g4tq0
        static let sandBoxApiKey = "sandbox_c7bvkfqad3ia366g4tqg"//sandbox_c6s97daad3ie4g2fd9j0 - sandbox_c7bvkfqad3ia366g4tqg
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
    }
    
    private init() {}
    
    //MARK:- Public
    //step 7 test search function (use an arrary of string before search response for testing
    public func search (query: String, completion: @escaping (Result<SearchResponse, Error>) -> Void) {
       
        //step 9 replace testing with a use of the generic url function and call your searchresponse
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        request(url: url(for: .search, queryParams: ["q": safeQuery]), expecting: SearchResponse.self, completion: completion)
        
        //fpr testing
        //guard let url = url(for: .search, queryParams: ["q" : query]) else {
        //            return
    }
    
    public func news(for type: NewsViewController.TypeOfContent, completion: @escaping (Result<[NewsStory], Error>) -> Void) {
        switch type {
        case .topStories:
            request(
                url: url(for: .topStories, queryParams: ["category": "general"]),
                expecting: [NewsStory].self,
                completion: completion
            )
        case .company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 7))
            request(
                url: url(for: .companyNews,
                            queryParams: ["symbol": symbol,
                                          "from": DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                                          "to": DateFormatter.newsDateFormatter.string(from: today)]),
                expecting: [NewsStory].self,
                completion: completion
            )
        }
    }
    
    public func marketData(
        for symbol: String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping (Result<MarketDataResponse, Error>) -> Void) {
            let today = Date().addingTimeInterval(-(Constants.day))
            let prior = today.addingTimeInterval(-(Constants.day * numberOfDays))
            let url = url(for: Endpoint.marketData, queryParams: [
                "symbol": symbol,
                "resolution": "1",
                "from": "\(Int(prior.timeIntervalSince1970))",
                "to": "\(Int(today.timeIntervalSince1970))"
            ])
            request(url: url, expecting: MarketDataResponse.self, completion: completion)
        }
    //MARK:- Private
    private enum Endpoint: String {
        case search //raw value of this case statement is "Search"
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
    }
    
    private enum APIError: Error {
        case invalidUrl
        case noDataReturned
    }

    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        //step 2 start to create URL query
        var urlString = Constants.baseUrl + endpoint.rawValue
        //step 3 add any params to the url
        var queryItems = [URLQueryItem]()
        //step 4 append query items to get search value and add token
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        queryItems.append(.init(name: "token", value: Constants.key))
        //step 5 convert query items suffix string
        urlString += "?" + queryItems.map { "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
        //step 6 return URLstring
        print("testing \(urlString)")
        return URL(string: urlString)
    }

    private func request<T: Codable>(url: URL?, expecting: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        //verify not null
        guard let url = url else { return }
        //perform get task
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.invalidUrl))
                return
            }
            do {
                let result = try JSONDecoder().decode(expecting, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(APIError.noDataReturned))
            }
        }
        task.resume()
    }
}
