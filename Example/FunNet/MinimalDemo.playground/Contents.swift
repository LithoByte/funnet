import FunNet
import Prelude
import Combine
import PlaygroundSupport

/**
 This minimal demo gives you the advantages of reusable endpoints while maintaining a focus on Foundation provided classes like URLRequest, URLComponents, and URLSession derivatives. This makes it easy to switch between different hosts and API versions while keeping all the endpoints the same.
 
 To do so, this example makes use of some lightweight extensions on those Foundation classes that make it easier to construct urls (`url(for: String, getParams: [URLQueryItem])`), set json headers (`addHeaders` paired with `jsonHeaders()`), separate call creation from firing (`asConnectable` which is the same as `makeConnectable` but allows non-`Never`error types), and generating server errors for handling.
 
 However, due to constraints from `dataTaskPublisher`, stubbing is not nearly as si,ple, and firing a call a second time requires resubscribing all listeners to new but identical publishers.
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
    
    let pub = appSession.dataTaskPublisher(for: request).share().asConnectable()
    
    pub.serverErrorPublisher().sink(receiveCompletion: doNothing(_:), receiveValue: doNothing(_:)).store(in: &cancellables)
    pub.map(\.data)
        .decode(type: Version.self, decoder: JSONDecoder())
        .sink(receiveCompletion: doNothing(_:),
              receiveValue: { print($0.version ?? "") })
        .store(in: &cancellables)
    
    // This will fire the network call
    pub.connect().store(in: &cancellables)
    
    // This does nothing; that is, if you want to make the same call again, you have to re-subscribe to new but identical publishers.
    // Compare this to the AllInDemo, where you can call the same network call and all the original subscribers will receive the new values.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        pub.connect().store(in: &cancellables)
    }
}
