import FunNet
import Prelude
import Combine

NSSetUncaughtExceptionHandler { exception in
    print("💥 Exception thrown: \(exception)")
    print(exception.name)
    print("\(exception.callStackSymbols.joined(separator: "\n"))")
}

public extension URLSession {
    func combineNetworkResponder(from request: URLRequest) -> CombineNetworkResponder {
        let responder = CombineNetworkResponder()
        let task = dataTask(with: request, completionHandler: responderToCompletion(responder: responder))
        responder.taskHandler(task)
        return responder
    }
}

let prodServer = URLComponents(string: "https://lithobyte.co/api/v1")

let sessionConfig = URLSessionConfiguration.default
sessionConfig.httpShouldSetCookies = false
sessionConfig.httpCookieAcceptPolicy = .never
let appSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)

struct User: Codable {
    var email: String?
    var password: String?
}

var endpoint = Endpoint()
endpoint.path = "sessions"
endpoint.httpMethod = "POST"
endpoint.postData = try? JSONEncoder().encode(User(email: "eschrock@lithobyte.co", password: "password"))
addJsonHeaders(&endpoint)

public func stub<T: Codable>(_ responder: CombineNetworkResponder, with model: T) -> (Fireable) -> Void {
    return { _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            responder.data = try? JSONEncoder().encode(model)
        }
    }
}

func doNothing<T>(_ t: T) {
    // NO OP
}

var cancellables = Set<AnyCancellable>()
if let request = prodServer?.request(for: endpoint) {
    let pub = appSession.dataTaskPublisher(for: request)
        .share()
        .asConnectable()
    
    pub.serverErrorPublisher()
        .sink(receiveCompletion: doNothing(_:),
              receiveValue: doNothing(_:))
        .store(in: &cancellables)
    pub.map(\.data)
        .decode(type: User.self, decoder: JSONDecoder())
        .sink(receiveCompletion: doNothing(_:),
              receiveValue: { print($0.email ?? "") })
        .store(in: &cancellables)
    
    pub.connect().store(in: &cancellables)
    
    let responder = appSession.combineNetworkResponder(from: request)
    responder.$dataTask.compactMap(id).sink(receiveValue: stub(responder, with: User(email: "eschrock@lithobyte.co", password: "password"))).store(in: &cancellables)
}
