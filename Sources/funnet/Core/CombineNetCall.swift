//
//  CombineNetCall.swift
//  FunNet
//
//  Created by Elliot Schrock on 2/4/24.
//

import Foundation
import UIKit
import Combine
import LithoOperators
#if canImport(Core)
    import Core
#endif

@available(iOS 13.0, *)
open class CombineNetCall: NetworkCall {
    @Published public var isInProgress: Bool = false
    public var publisher: CombineNetworkResponder
    
    public init(configuration: ServerConfiguration, _ endpoint: Endpoint, responder: CombineNetworkResponder = CombineNetworkResponder()) {
        publisher = responder
        super.init(configuration: configuration, endpoint: endpoint, responder: responder)
        setupProgressPublisher()
    }
    
    public init(session: URLSession, baseUrlComponents: URLComponents, endpoint: Endpoint, responder: CombineNetworkResponder = CombineNetworkResponder()) {
        publisher = responder
        super.init(session: session, baseUrlComponents: baseUrlComponents, endpoint: endpoint, responder: responder)
    }
    
    public init(sessionConfig: URLSessionConfiguration, baseUrlComponents: URLComponents, endpoint: Endpoint, responder: CombineNetworkResponder = CombineNetworkResponder()) {
        publisher = responder
        super.init(sessionConfig: sessionConfig, baseUrlComponents: baseUrlComponents, endpoint: endpoint, responder: responder)
    }
    
    open override func fire() {
        isInProgress = true
        firingFunc(self)
    }
    
    open func setIsInProgressBlock(to newValue: Bool) -> () -> Void {
        return { [weak self] in
            if self?.isInProgress != newValue {
                self?.isInProgress = newValue
            }
        }
    }
    
    open func setupProgressPublisher() {
        publisher.responseHandler <>= { [weak self] _ in self?.setIsInProgressBlock(to: false)() }
        publisher.httpResponseHandler <>= { [weak self] _ in self?.setIsInProgressBlock(to: false)() }
        publisher.dataHandler <>= { [weak self] _ in self?.setIsInProgressBlock(to: false)() }
        publisher.errorHandler <>= { [weak self] _ in self?.setIsInProgressBlock(to: false)() }
        publisher.serverErrorHandler <>= { [weak self] _ in self?.setIsInProgressBlock(to: false)() }
        publisher.errorDataHandler <>= { [weak self] _ in self?.setIsInProgressBlock(to: false)() }
    }
}

public extension CombineNetCall {
    func managePagedModels<Root, T>(on root: Root,
                                    atKeyPath arrayKeyPath: WritableKeyPath<Root, [T]?>,
                                    firstPageValue: Int = 1,
                                    _ pageKey: String = "page",
                                    parser: @escaping (Data) -> [T]?) -> AnyCancellable {
        return publisher.$data
            .compactMap { $0 }
            .compactMap(parser)
            .sink { [weak self] models in
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

@available(iOS 13.0, *)
public class CombineNetworkResponder: NetworkResponder {
    @Published public var dataTask: URLSessionDataTask?
    @Published public var response: URLResponse?
    @Published public var httpResponse: HTTPURLResponse?
    @Published public var data: Data?
    @Published public var error: NSError?
    @Published public var serverError: NSError?
    @Published public var errorResponse: URLResponse?
    @Published public var errorData: Data?
    
    public override init() {
        super.init()
        self.taskHandler = { [weak self] in self?.dataTask = $0 }
        self.responseHandler = { [weak self] in self?.response = $0 }
        self.httpResponseHandler = { [weak self] in self?.httpResponse = $0 }
        self.dataHandler = { [weak self] in self?.data = $0 }
        self.errorHandler = { [weak self] in self?.error = $0 }
        self.serverErrorHandler = { [weak self] in self?.serverError = $0 }
        self.errorDataHandler = { [weak self] in self?.errorData = $0 }
    }
}

@available(iOS 13.0, *)
public extension Publisher {
    func asConnectable() -> Publishers.MakeConnectable<Self> {
        return .init(upstream: self)
    }
}

@available(iOS 13.0, *)
public extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {
    func serverErrorPublisher() -> Publishers.Map<Self, NSError?> {
        return self.map(responseToServerError())
    }
}

@available(iOS 13.0, *)
public extension URLSession {
    func combineNetworkResponder(from request: URLRequest) -> CombineNetworkResponder {
        let responder = CombineNetworkResponder()
        let task = dataTask(with: request, completionHandler: responderToCompletion(responder: responder))
        responder.taskHandler(task)
        return responder
    }
}

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
