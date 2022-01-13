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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSearchController()
        setupTitleView()
        setupFloatingPanel()
        
    }
    
    // MARK: - Private
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
