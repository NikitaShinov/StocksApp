//
//  TopStoriesViewController.swift
//  StocksApp
//
//  Created by max on 14.12.2021.
//

import UIKit

class NewsViewController: UIViewController {
    
    enum TypeOfContent {
        case topStories
        case company(symbol: String)
        
        var  title: String {
            switch self {
            case .topStories:
                return "Top Stories"
            case .company(let symbol):
                return symbol.uppercased()
            }
        }
    }
    
    // MARK: - Properties
    
    private var stories = [String]()

    let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        table.backgroundColor = .clear
        return table
    }()
    
    private let type: TypeOfContent
    
    // MARK: - Initializers
    
    init(type: TypeOfContent) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: - Private functions
    
    private func setupTable() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchNews() {
        
    }
    
    private func open(url: URL) {
        
    }

}

extension NewsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        header.configure(with: .init(title: self.type.title, shouldShowAddButton: false))
        return header
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
