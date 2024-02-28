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
        endpoint.incrementPageParams(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
        reset = { call in
            let resetEndpoint = defaultResetEndpoint(pageKey: pageKey, perPage: perPage, countKey: countKey, firstPage: firstPage)
            resetEndpoint(&call.endpoint)
        }
        fire()
    }
    
    func pagedModelsPipeline<T>(firstPageValue: Int = 1, _ pageKey: String = "page") -> ([T], [T]) -> [T] {
        return { [weak self] oldModels, newModels in
            var updatedModels = [T]()
            if let isFirstPage = self?.endpoint.isFirstPage(firstPageValue: firstPageValue, pageKey), !isFirstPage {
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

public extension Endpoint {
    mutating func incrementPageParams(pageKey: String = "page", perPage: Int = 20, countKey: String = "count", firstPage: Int = 1) {
        if let oldPage = currentPage(pageKey) {
            let pageParam = URLQueryItem(name: pageKey, value: "\(oldPage + 1)")
            getParams = getParams.filter(^\.name >>> isEqualTo(pageKey) >>> (!))
            addGetParams(params: [pageParam])
        } else {
            let pageParam = URLQueryItem(name: pageKey, value: "\(firstPage)")
            let countParam = URLQueryItem(name: countKey, value: "\(perPage)")
            addGetParams(params: [pageParam, countParam])
        }
    }
    
    func currentPage(_ keyName: String = "page") -> Int? {
        getParams.filter(^\.name >>> isEqualTo(keyName)).compactMap(\.value).compactMap(Int.init).first
    }
    
    func isFirstPage(firstPageValue: Int = 1, _ pageKey: String = "page") -> Bool {
        let current = currentPage(pageKey)
        return !(current == nil || current == firstPageValue)
    }
}

public func defaultResetEndpoint(pageKey: String = "page", perPage: Int = 20, countKey: String = "count", firstPage: Int = 1) -> (inout Endpoint) -> Void {
    return {
        let pageParam = URLQueryItem(name: pageKey, value: "\(firstPage)")
        $0.getParams = $0.getParams.filter(^\.name >>> isEqualTo(pageKey) >>> (!))
        $0.addGetParams(params: [pageParam])
    }
}
