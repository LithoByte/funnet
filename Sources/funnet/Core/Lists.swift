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
    -> (_ currentItem: Int, _ totalItems: Int) -> Void {
        return { [weak self] (currentItem, totalItems) in
            if shouldLoadNextPage(pageSize, pageTrigger, totalItems, currentItem) {
                self?.nextPage(pageKey: pageKey, perPage: pageSize, countKey: countKey, firstPage: firstPage)
            }
        }
    }
    
    func pager(pageSize: Int = 20,
               pageTrigger: Int = 5,
               pageKey: String = "page",
               countKey: String = "count",
               firstPage: Int = 1,
               shouldLoadNextPage: @escaping (Int, Int, Int, Int) -> Bool = defaultShouldLoadNextPage)
    -> (UITableViewCell, UITableView, IndexPath) -> Void {
        return { [weak self] (cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) in
            let previousIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            if tableView.indexPathsForVisibleRows?.contains(previousIndexPath) == true {
                let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
                if shouldLoadNextPage(pageSize, pageTrigger, numberOfRows, indexPath.row) {
                    self?.nextPage(pageKey: pageKey, perPage: pageSize, countKey: countKey, firstPage: firstPage)
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
        return { [weak self] (collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) in
            let previousIndexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
            if collectionView.indexPathsForVisibleItems.contains(previousIndexPath) == true {
                let numberOfRows = collectionView.numberOfItems(inSection: indexPath.section)
                if shouldLoadNextPage(pageSize, pageTrigger, numberOfRows, indexPath.item) {
                    self?.nextPage(pageKey: pageKey, perPage: pageSize, countKey: countKey, firstPage: firstPage)
                }
            }
        }
    }
    
    func nextPage(pageKey: String = "page", perPage: Int = 20, countKey: String = "count", firstPage: Int = 1) {
        if let oldPage = currentPage(pageKey) {
            let pageParam = URLQueryItem(name: pageKey, value: "\(oldPage + 1)")
            endpoint.getParams = endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey) >>> (!))
            endpoint.addGetParams(params: [pageParam])
        } else {
            let pageParam = URLQueryItem(name: pageKey, value: "\(firstPage)")
            let countParam = URLQueryItem(name: countKey, value: "\(perPage)")
            endpoint.addGetParams(params: [pageParam, countParam])
        }
        reset = { call in
            let pageParam = URLQueryItem(name: pageKey, value: "\(firstPage)")
            call.endpoint.getParams = call.endpoint.getParams.filter(^\.name >>> isEqualTo(pageKey) >>> (!))
            call.endpoint.addGetParams(params: [pageParam])
        }
        fire()
    }
    
    func currentPageFunction(_ keyName: String = "page") -> () -> Int? {
        return { [weak self] in self?.currentPage(keyName) }
    }
    
    func currentPage(_ keyName: String = "page") -> Int? {
        endpoint.getParams.filter(^\.name >>> isEqualTo(keyName)).compactMap(\.value).compactMap(Int.init).first
    }
    
    func shouldAppendNewModels(firstPageValue: Int = 1, _ pageKey: String = "page") -> Bool {
        let current = self.currentPage(pageKey)
        return !(current == nil || current == firstPageValue)
    }
    
    func pagedModelsPipeline<T>(firstPageValue: Int = 1, _ pageKey: String = "page") -> ([T], [T]) -> [T] {
        return { [weak self] oldModels, newModels in
            var updatedModels = [T]()
            if let shouldAppend = self?.shouldAppendNewModels(firstPageValue: firstPageValue, pageKey), shouldAppend {
                updatedModels = oldModels
            }
            updatedModels.append(contentsOf: newModels)
            return updatedModels
        }
    }
    
    func managePagedModels<Root, T>(on root: Root, atKeyPath arrayKeyPath: WritableKeyPath<Root, [T]?>, firstPageValue: Int = 1, _ pageKey: String = "page") -> ([T]) -> Void {
        return { [weak self] models in
            var copy = root
            if var allModels = root[keyPath: arrayKeyPath], 
                let updatedModels = self?.pagedModelsPipeline(firstPageValue: firstPageValue, pageKey)(allModels, models) {
                copy[keyPath: arrayKeyPath] = updatedModels
            } else {
                copy[keyPath: arrayKeyPath] = models
            }
        }
    }
}
