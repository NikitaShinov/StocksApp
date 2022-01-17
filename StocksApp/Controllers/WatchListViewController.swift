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
    
    static var maxChangewidth: CGFloat = 0 
    //Model
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    //ViewModels
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        table.separatorStyle = .none
        return table
    }()
    
    private var observer: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setUpTableView()
        fetchWatchListData()
        setupFloatingPanel()
        setupTitleView()
        setupOserver()
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private
    private func setupOserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .didAddToWatchList,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                self?.viewModels.removeAll()
                self?.fetchWatchListData()
        })
    }
    
    private func setUpTableView() {
        view.addSubviews(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchWatchListData() {
        let symbols = PersistanceManager.shared.watchlist
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
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
            let changePercentage = getchangePercentage(symbol: symbol, data: candleSticks)
            viewModels.append(.init(symbol: symbol,
                                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                                    price: getLatestClosingPrice(from: candleSticks),
                                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                                    changePercentage: String.percentage(from: changePercentage),
                                    chartViewModel: .init(data: candleSticks.reversed().map { $0.close },
                                                          showLegend: false,
                                                          showAxis: false,
                                                          fillColor: changePercentage < 0 ? .systemRed : .systemGreen)))
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
        HapticsManager.shared.vibrateForSelection()
        let vc = StockDetailsViewController(symbol: searchResult.displaySymbol,
                                            companyName: searchResult.description)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.delegate = self
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            //Update persistence
            PersistanceManager.shared.removeFromWatchList(symbol: viewModels[indexPath.row].symbol)
            //Update viewmodels
            viewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //Open details for selection
        HapticsManager.shared.vibrateForSelection()
        let viewModel = viewModels[indexPath.row]
        let vc = StockDetailsViewController(symbol: viewModel.symbol,
                                            companyName: viewModel.companyName,
                                            candleStickData: watchlistMap[viewModel.symbol] ?? [])
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
}

extension WatchListViewController: WatchListTableViewCellDelegate {
    func didUpdateMaxWidth() {
        // Optimize: Only refresh rows prior to th current row that changes the max width
        tableView.reloadData()
    }
}
