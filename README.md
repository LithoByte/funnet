# FunNet

[![CI Status](https://circleci.com/gh/schrockblock/FunNet.svg?style=svg)](https://circleci.com/gh/schrockblock/funnet)
[![Version](https://img.shields.io/cocoapods/v/FunNet.svg?style=flat)](https://cocoapods.org/pods/FunNet)
[![License](https://img.shields.io/cocoapods/l/FunNet.svg?style=flat)](https://cocoapods.org/pods/FunNet)
[![Platform](https://img.shields.io/cocoapods/p/FunNet.svg?style=flat)](https://cocoapods.org/pods/FunNet)

## Example

FunNet lets you build network calls using three main parts: a server configuration, an endpoint, and a responder. You can customize each of those as you need, but it also provides ready made solutions for you. These three elements can be combined into a `NetworkCall`, which you can then call `fire()` on to fire your network call.

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

func getSomeCall(config: ServerConfiguration = Current.serverConfig) -> CombineNetCall {
  let endpoint = Endpoint()
  // ...configure endpoint...
  return CombineNetCall(config, endpoint)
}
```

## Requirements

## Installation

FunNet is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FunNet', git: 'https://github.com/schrockblock/funnet'
```

You can also use one of the subspecs:

```ruby
pod 'FunNet/Core', git: 'https://github.com/schrockblock/funnet'
pod 'FunNet/Combine', git: 'https://github.com/schrockblock/funnet'
pod 'FunNet/ReactiveSwift', git: 'https://github.com/schrockblock/funnet'
```

depending on how you'd like to interact with your responders.

## Author

Elliot Schrock

## License

FunNet is available under the MIT license. See the LICENSE file for more info.
