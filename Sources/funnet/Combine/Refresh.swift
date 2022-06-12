//
//  Refresh.swift
//  FunNet
//
//  Created by Elliot Schrock on 6/12/22.
//

import Combine

public extension CombineNetCall {
    func refresh(from tableView: UITableView, _ cancelBag: inout Set<AnyCancellable>) {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.resetAndFire), for: .valueChanged)
        $isInProgress.sink { $0 ? refresher.beginRefreshing() : refresher.endRefreshing() }.store(in: &cancelBag)
        tableView.refreshControl = refresher
    }
    
    func refresh(from collectionView: UICollectionView, _ cancelBag: inout Set<AnyCancellable>) {
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(self.resetAndFire), for: .valueChanged)
        $isInProgress.sink { $0 ? refresher.beginRefreshing() : refresher.endRefreshing() }.store(in: &cancelBag)
        collectionView.refreshControl = refresher
    }
}
