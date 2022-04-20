import FunNet
import Prelude
import Combine
import PlaygroundSupport

/**
 This mix-and-match demo gives you some of the advantages of FunNet while preserving much of the pure URLSession style. That means:
 1. It's easy to switch between different hosts and API versions while keeping all the endpoints the same
 2. The logic for setting up a network call and firing it is separate, so entirely different classes can handle those two responsibilities.
 3. It's very simple to mock server responses.
 4. Response handling is atomized so it's easy to have different classes handle different aspects of a server response, eg error handling or json parsing
 Unfortunately, it's still a little tricky to fire a network call more than once, simply because data tasks only really want to be `resume`d once.
 */

PlaygroundPage.current.needsIndefiniteExecution = true
NSSetUncaughtExceptionHandler { exception in
    print("💥 Exception thrown: \(exception)")
    print(exception.name)
    print("\(exception.callStackSymbols.joined(separator: "\n"))")
}

struct Version: Codable { var version: String? }
func doNothing<T>(_ t: T) { /* NO OP */ }
var cancellables = Set<AnyCancellable>()

let prodServer = URLComponents(string: "https://trill-api-staging.herokuapp.com/api/v1")

let sessionConfig = URLSessionConfiguration.default
sessionConfig.httpShouldSetCookies = false
sessionConfig.httpCookieAcceptPolicy = .never
let appSession = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: .main)

func configureVersionRequest(_ request: inout URLRequest) {
    request.httpMethod = "GET"
    request.addHeaders(jsonHeaders())
}

if let url = prodServer?.url(for: "version") {
    var request = URLRequest(url: url)
    configureVersionRequest(&request)
    
    let publisher = appSession.combineNetworkResponder(from: request)
    
    publisher.$serverError.sink(receiveValue: doNothing).store(in: &cancellables)
    publisher.$error.sink(receiveValue: doNothing).store(in: &cancellables)
    publisher.$data.compactMap(id)
        .decode(type: Version.self, decoder: JSONDecoder())
        .sink(receiveCompletion: doNothing,
              receiveValue: { print($0.version ?? "") })
        .store(in: &cancellables)
    
    // this is stubbing, which also "fires" the call simultaneously
    publisher.$dataTask
        .compactMap(id)
        .sink(receiveValue: stub(publisher, with: Version(version: "1.0.1")))
        .store(in: &cancellables)
}
