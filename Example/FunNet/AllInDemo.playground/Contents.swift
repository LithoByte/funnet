import FunNet
import Prelude
import Combine
import PlaygroundSupport

/**
 This "all in" demo gives you all the advantages of this networking library. That means:
 1. It's easy to switch between different hosts and API versions while keeping all the endpoints the same
 2. The logic for setting up a network call and firing it is separate, so entirely different classes can handle those two responsibilities.
 3. It's very simple to mock server responses.
 4. Response handling is atomized so it's easy to have different classes handle different aspects of a server response, eg error handling or json parsing
 5. Making the same call again, or after a minor change, is as easy as calling `fire` again, and all subscribers will have access the new response.
 Note that this demo is shorter than the minimal demo but includes stubbing, which minimal does not.
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

let prodServerConfig = ServerConfiguration(host: "trill-api-staging.herokuapp.com", apiRoute: "api/v1")

func versionEndpoint() -> Endpoint {
    var endpoint = Endpoint()
    endpoint.path = "version"
    endpoint.httpMethod = "GET"
    addJsonHeaders(&endpoint)
    return endpoint
}

let call = CombineNetCall(configuration: prodServerConfig, versionEndpoint())

call.publisher.$serverError.sink(receiveValue: doNothing).store(in: &cancellables)
call.publisher.$error.sink(receiveValue: doNothing).store(in: &cancellables)
call.publisher.$data.compactMap(id)
    .decode(type: Version.self, decoder: JSONDecoder())
    .sink(receiveCompletion: doNothing,
          receiveValue: { print($0.version ?? "") })
    .store(in: &cancellables)

call.firingFunc = stub(call.publisher, with: Version(version: "1.0.0"))

call.fire()

// This fires the call again, and all subscribers will receive the new values.
DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: call.fire)
