//
//  ViewController.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    //step 13 declare a timer
    private var searchTimer: Timer?
    
    private var panel: FloatingPanelController?
    //Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    //ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView: UITableView = {
       let table = UITableView()
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setUpTableView()
        fetchWatchListData()
        setupFloatingPanel()
        setupTitleView()
        
        
    }
    
    // MARK: - Private
    private func setUpTableView() {
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchWatchListData() {
        let symbols = PersistanceManager.shared.watchlist
        let group = DispatchGroup()
        
        for symbol in symbols {
            group.enter()
            APICaller.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                switch result {
                case .success(let data):
                    let candleSticks = data.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print (error)
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    private func createViewModels() {
        var viewModels = [WatchListTableViewCell.ViewModel]()
        
        for (symbol, candleSticks) in watchlistMap {
            let changepercentage = getchangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(.init(symbol: symbol,
                                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                                    price: getLatestClosingPrice(from: candleSticks),
                                    changeColor: changepercentage < 0 ? .systemRed : .systemGreen,
                                    changePercentage: String.percentage(from: changepercentage)))
        }
        self.viewModels = viewModels
    }
    
    private func getchangePercentage(symbol: String,  data: [CandleStick]) -> Double {
        let latestDate = data[0].date
        guard let latestClose = data.first?.close,
              let priorClose = data.first(where: {!Calendar.current.isDate($0.date, inSameDayAs: latestDate)})?.close else {
            return 0
        }
        let diff = 1 - (priorClose / latestClose)
        return diff
    }
    
    private func getLatestClosingPrice (from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
                return String.formatted(number: closingPrice)
    }
    
    private func setupFloatingPanel() {
        let panel = FloatingPanelController()
        let vc = NewsViewController(type: .topStories)
        panel.surfaceView.backgroundColor = .secondarySystemBackground
        panel.set(contentViewController: vc)
        panel.addPanel(toParent: self)
        panel.delegate = self
        panel.track(scrollView: vc.tableView)
    }
    
    private func setupSearchController() {
        let resultViewController = SearchResultsViewController()
        resultViewController.delegate = self
        let searchViewController = UISearchController(searchResultsController: resultViewController)
        searchViewController.searchResultsUpdater = self //we can get user taps
        navigationItem.searchController = searchViewController
    }
    
    private func setupTitleView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))
        let lable = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width-20, height: titleView.height))
        lable.text = "Stocks"
        lable.font = .systemFont(ofSize: 35, weight: .medium)
        titleView.addSubview(lable)
        navigationItem.titleView = titleView
    }
    
}
extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsViewController =  searchController.searchResultsController as? SearchResultsViewController,
                  !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        //call api here to search here
        //step 11 call your api
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APICaller.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsViewController.update(with: response.result)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        resultsViewController.update(with: [])
                    }
                    print(error)
                }
            }
        })
    }
}

//step 12 update all deletegates with SearchResult not string
extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        let vc = StockDetailsViewController()
        let navVC = UINavigationController(rootViewController: vc)
        vc.title = searchResult.description
        present(navVC, animated: true)
    }
}

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
        navigationItem.searchController?.searchBar.isHidden = fpc.state == .full
    }
}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchlistMap.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Open details for selection
    }
    
}
