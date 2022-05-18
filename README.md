# FunNet

[![CI Status](https://circleci.com/gh/LithoByte/funnet/tree/master.svg?style=shield)](https://circleci.com/gh/LithoByte/funnet)
[![Version](https://img.shields.io/cocoapods/v/FunNet.svg?style=flat)](https://cocoapods.org/pods/FunNet)
[![License](https://img.shields.io/cocoapods/l/FunNet.svg?style=flat)](https://cocoapods.org/pods/FunNet)
[![Platform](https://img.shields.io/cocoapods/p/FunNet.svg?style=flat)](https://cocoapods.org/pods/FunNet)

## Why FunNet?

There are 5 reasons why: 
### 1. It's easy to switch between different hosts and API versions while keeping all the endpoints the same. 
That means switching between local, staging, and prod has never been easier.
### 2. The logic for setting up a network call and firing it is separate. 
Entirely different classes can handle those two responsibilities. This is a vast improvement for SRP, and greatly simplifies logic throughout your app.
### 3. It's very simple to mock server responses – and equally simple to switch back to live responses. 
That means you can easily develop based on a server contract, and then remove one line of code to switch to the live server (on a per endpoint basis so it doesn't affect other in-process endpoints).
### 4. Response handling is atomized so it's easy to have different classes handle different aspects of a server response, eg error handling or json parsing.
Does your error handling code need to live in the same class as the happy path code? Does your activity indicator view need to know what the type of data the call returns? Probably not. Separate those concerns simply and easily, without further abstraction.
### 5. Making the same call again, or after a minor change, is as easy as calling `fire` again, and all subscribers will have access the new response.
Many other libraries, and indeed, URLSession itself, require you to create a whole new object in order to fire the same call again. That means any subscribers need to be re-subscribed to the results of the call all over again, each time. Not so with FunNet – just call `fire` on your network call!

## Contents

- [Networking](#networking)
- [Multipart](#multipart)
- [Error Handling](#error-handling)

## Networking

FunNet lets you build network calls using three main parts: a **server configuration**, an **endpoint**, and a network **responder**. You can customize each of those as you need, but it also provides ready made solutions for you. These three elements can be combined into a `NetworkCall`, which you can then call `fire()` on to execute the server call.

By separating these elements, FunNet gives you a lot of flexibility with very little code. The server is independent from the endpoint, which is independent from what you choose to do with the response. This way, it becomes very easy swap out pieces without affecting anything else. 

For instance, in different environments you might want to swap out different servers – say, a test configuration for tests, a staging server for new functionality, and a prod server for the App Store version. This is easy as pie! Just create three server configs and conditionally pass them to your calls depending on your environment.

So something like this:

```swift
let prodConfig = ServerConfiguration(host: "lithobyte.co", "v3")
let stagingConfig = ServerConfiguration(host: "staging.lithobyte.co", "v3")
let testConfig = ServerConfiguration(shouldStub: true, host: "lithobyte.co", "v3")

struct World {
  var serverConfig: ServerConfiguration
}
let prod = World(serverConfig: prodConfig)
let staging = World(serverConfig: staging)
let testing = World(serverConfig: testConfig)

var Current = prod

func getSomeEndpoint(config: ServerConfiguration = Current.serverConfig) -> CombineNetCall {
  var endpoint = Endpoint()
  
  // configure endpoint
  endpoint.httpMethod = "POST"
  endpoint.path = path
  addJsonHeaders(&endpoint)
  endpoint.getParams = ["page": 3]
  
  return CombineNetCall(config, endpoint)
}
```

## Multipart

You could also use our multipart encoder to upload large files:

```swift
func uploadAvatarCall(config: ServerConfiguration = Current.serverConfig, ) -> CombineNetCall {
  let encoder = FormDataEncoder()
  let stream = try? encoder.encode(imageDoc, boundary: "--boundary-pds-site\(Date().timeIntervalSince1970)file-image-boundary--")
  
  var endpoint = Endpoint()
  endpoint.httpMethod = "POST"
  endpoint.dataStream = stream?.makeInputStream()
  addMultipartHeaders(&endpoint, from: stream!)
  
  return CombineNetCall(config, endpoint)
}
struct ImageDoc: Codable {
    var title: String?
    var file: JpgImage?
}  
```

where `JpgImage` is just a thin wrapper over `UIImage` that includes the quality of the JPG and which can be created simply by calling `jpgImage(ofQuality: 0.8)` on a `UIImage`.

You don't need to use it with FunNet calls though! You can also use it directly on a URL request:

```swift
let stream = try? FormDataEncoder().encode(imageDoc, boundary: "--boundary-pds-site\(Date().timeIntervalSince1970)file-image-boundary--")

let request = URLRequest(url: URL(string: "https://lithobyte.co/api/v1")!)
request.httpMethod = "POST"
request.httpBodyStream = stream?.makeInputStream()
// add headers, etc

```

## Error Handling

Finally, you could use our error handling functions to elegantly handle server and url loading errors, returned either from our net calls or from URLSession style networking directly. If you're using Combine extensions for URLSession, it's as simple as:

```swift
let vc = UIViewController()
var cancelBag: Set<AnyCancellable> = []

let request = URLRequest(url: URL(string: "https://lithobyte.co/api/v1")!)
let session = URLSession(configuration: .default)
var taskPub = session.dataTaskPublisher(for: request).eraseToAnyPublisher()

// handle errors
taskPub
    .sink(receiveCompletion: debugTaskErrorAlerter(), receiveValue: debugURLResponseHandler)
    .store(in: &cancelBag)
    
// handle success
taskPub
    .sink(receiveCompletion: doNothing, receiveValue: handleSuccessFunctionGoesHere)
    .store(in: &cancelBag)
```

The completion handler handles URL loading errors, eg no internet, while the value handler deals with server response codes greater than 400, eg, 404 not found. Both filter for only when errors occur, so you can subscribe to handle success separately.

## Requirements

The `Core` and most other subspecs requires iOS 11 and up. The exception is the `Combine` subspec, which (predictably) requires iOS 13.

## Installation

FunNet is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FunNet', git: 'https://github.com/LithoByte/funnet'
```

You can also use one of the subspecs:

```ruby
pod 'FunNet/Core', git: 'https://github.com/LithoByte/funnet'
pod 'FunNet/Combine', git: 'https://github.com/LithoByte/funnet'
pod 'FunNet/ReactiveSwift', git: 'https://github.com/LithoByte/funnet'
```

depending on how you'd like to interact with your responders.  You can also just grab our multipart encoder or error handling functions with their respective subspecs:

```ruby
pod 'FunNet/Multipart', git: 'https://github.com/LithoByte/funnet'
pod 'FunNet/ErrorHandling', git: 'https://github.com/LithoByte/funnet'
```

## Author

Elliot Schrock

## License

FunNet is available under the MIT license. See the LICENSE file for more info.
