//
//  ViewController.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import UIKit

class WatchListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpSearchController()
        setupTitleView()
    }
    
    private func setupTitleView() {
        let titleview = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 0))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleview.width-20, height: titleview.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 40, weight: .medium)
        titleview.addSubview(label)
        
        navigationItem.titleView = titleview
    }
    
    private func setUpSearchController () {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
    }


}

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsUpdater as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        resultsVC.update(with: ["GOOG"])
    }
}

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: String) {
        
    }
}
