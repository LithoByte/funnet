//
//  Lists.swift
//  FunNet
//
//  Created by Elliot Schrock on 6/12/22.
//

import UIKit
import LithoOperators
import Prelude

public func defaultShouldLoadNextPage(_ pageSize: Int = 20, _ pageTrigger: Int = 5, _ numberOfRows: Int, _ current: Int) -> Bool {
    return numberOfRows - current == pageTrigger && numberOfRows % pageSize == 0
}

public extension NetworkCall {
    func pager(pageSize: Int = 20,
               pageTrigger: Int = 5,
               pageKey: String = "page",
               countKey: String = "count",
               firstPage: Int = 1,
               shouldLoadNextPage: @escaping (Int, Int, Int, Int) -> Bool = defaultShouldLoadNextPage)
    -> (UITableViewCell, UITableView, IndexPath) -> Void {
        return { (cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) in
            let previousIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if tableView.indexPathsForVisibleRows?.contains(previousIndexPath) == true {
                let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
                if shouldLoadNextPage(pageSize, pageTrigger, numberOfRows, indexPath.row) {
                    self.nextPage(pageKey: pageKey, perPage: pageSize, countKey: countKey, firstPage: firstPage)
                }
            }
        }
    }
    
    func pager(pageSize: Int = 20,
               pageTrigger: Int = 4,
               pageKey: String = "page",
               countKey: String = "count",
               firstPage: Int = 1,
               shouldLoadNextPage: @escaping (Int, Int, Int, Int) -> Bool = defaultShouldLoadNextPage)
    -> (UICollectionView, UICollectionViewCell, IndexPath) -> Void {
        return { (collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) in
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            if collectionView.indexPathsForVisibleItems.contains(previousIndexPath) == true {
                let numberOfRows = collectionView.numberOfItems(inSection: indexPath.section)
                if shouldLoadNextPage(pageSize, pageTrigger, numberOfRows, indexPath.item) {
                    self.nextPage(pageKey: pageKey, perPage: pageSize, countKey: countKey, firstPage: firstPage)
                }
            }
        }
    }
    
    func nextPage(pageKey: String = "page", perPage: Int = 20, countKey: String = "count", firstPage: Int = 1) {
        let params = self.endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey))
        if var pageParam = params.first, let oldValue = pageParam.value, let oldPage = Int(oldValue) {
            pageParam.value = "\(oldPage + 1)"
            self.endpoint.getParams = self.endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey) >>> (!))
            self.endpoint.addGetParams(params: [pageParam])
        } else {
            let pageParam = URLQueryItem(name: pageKey, value: "\(firstPage)")
            let countParam = URLQueryItem(name: countKey, value: "\(perPage)")
            self.endpoint.addGetParams(params: [pageParam, countParam])
        }
        self.fire()
    }
}
