//
//  SearchResultsViewController.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidSelect (searchResult: String)
}

class SearchResultsViewController: UIViewController {
    
    weak var delegate: SearchResultsViewControllerDelegate?
    private var results: [String] = []
    
    private let tableview: UITableView = {
        let table = UITableView()
        table.register(SearchResultTableViewCell.self,
                       forCellReuseIdentifier: SearchResultTableViewCell.identifier)
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        
        setUpTable ()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableview.frame = view.bounds
    }
    
    private func setUpTable () {
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    public func update(with results: [String]) {
        self.results = results
        tableview.reloadData()
    }
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableViewCell.identifier, for: indexPath)
        
        
        cell.textLabel?.text = "AAPL"
        cell.detailTextLabel?.text = "Apple Inc."
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultsViewControllerDidSelect(searchResult: "AAPL")
    }
}
