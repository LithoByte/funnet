# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project shape

FunNet is an iOS networking library distributed as **both** a CocoaPod (`FunNet.podspec`, with subspecs) and a Swift Package (`Package.swift`). Both consumers point at the same source tree under `Sources/funnet/{Core,TCA,Multipart,ErrorHandling,ErrorHandlingCombine}`. When you add a file, make sure it lands in a directory that is picked up by the relevant subspec **and** the matching SwiftPM target. Note: `CombineNetCall` lives in `Sources/funnet/Core/`, not under a separate `Combine/` directory, even though the podspec declares a `Combine` subspec pointing at `Sources/funnet/Combine/**/*.swift`.

Heavy use of LithoOperators / Prelude function-composition operators (`|>`, `>>>`, `<>=`, `^\`, `~`). Don't "clean these up" into vanilla Swift — they're load-bearing and intentional throughout the codebase.

## Build & test

The package can be opened in Xcode directly via `Package.swift`, but the **canonical test setup lives in `Example/`** (the `Tests/funnetTests/` target in SwiftPM is empty — all real tests are in `Example/Tests/`).

To run tests locally (mirrors CI in `.circleci/config.yml`):

```sh
cd Example
pod install
bundle install
bundle exec fastlane scan        # scheme: FunNet-Example
```

Or directly with xcodebuild:

```sh
cd Example
xcodebuild test -workspace FunNet.xcworkspace -scheme FunNet-Example -destination 'platform=iOS Simulator,name=iPhone 15'
```

To run a single test, pass `-only-testing:FunNet_Tests/<TestClass>/<testMethod>` to `xcodebuild test`.

To validate the podspec: `pod lib lint FunNet.podspec` (or `pod spec lint`).

## Architecture

A network call is composed of three orthogonal pieces, each swappable independently:

1. **`ServerConfiguration`** — host/scheme/apiBaseRoute/`URLSessionConfiguration`. Swap to point at staging vs prod vs stubbed.
2. **`Endpoint`** (struct) — path, HTTP method, headers, query params, body. Pure value type, easy to mutate or copy per call.
3. **Responder / output** — varies by flavor (see below).

These are combined into a `NetworkCall` (or one of its siblings) that you `fire()`. The key extensibility point is `firingFunc`, a closure on each call type. Stubbing works by replacing `firingFunc` rather than wrapping the call — see `stub(_:with:)` and `stubHTTPResponse(_:withStatusCode:)` in `NetworkResponder.swift`. Tests should follow this pattern, not mock URLSession.

Four call flavors exist, all sharing the same `ServerConfiguration` + `Endpoint` foundation:

| Type | Module | Output mechanism |
|------|--------|------------------|
| `NetworkCall` | Core | Callbacks via `NetworkResponder` (split handlers for response, http response, data, NSError, server error, error data) |
| `CombineNetCall` | Core (iOS 13+) | `CombineNetworkResponder` exposes `@Published` properties; also publishes `isInProgress` |
| `AsyncNetworkCall` / `ParsingNetworkCall<T>` | Core | `async throws -> Data?`; `ParsingNetworkCall` adds `fireAndParse() async -> T?` |
| `NetCallReducer` | TCA | `Reducer` with `State`/`Action.fire`/`refresh`/`nextPage` and a `.delegate(.responseData/.error)` boundary; `mockFire` for tests |

Paging is built into `Endpoint` (`incrementPageParams`, `currentPage`, `defaultResetEndpoint`) and surfaces as `pager(...)` extensions on `NetworkCall` for table/collection views, and as the `nextPage` action on `NetCallReducer`. When implementing a new paging-aware call, prefer extending these primitives over reimplementing pagination.

`Multipart/` contains a standalone form-data encoder (`FormDataEncoder`, `MultipartFormData`, `SerialInputStream`) usable independently of the rest of FunNet — it just produces an `InputStream` you assign to `Endpoint.dataStream` (or any `URLRequest.httpBodyStream`).

`ErrorHandling/` and `ErrorHandlingCombine/` provide pluggable error responders that turn server/URL-loading errors into UIAlertController presentations, debug logging, etc., and are designed to compose onto a `NetworkResponder` rather than replace it.

## Conventions

- Public API is mostly free functions + small structs/classes; method extensions are added via `public extension` rather than subclassing. Match this style.
- The `firingFunc` pattern (replaceable closure on the call object) is the supported extension point for behavior changes (logging, retries, stubbing). Don't subclass to override `fire()`.
- Subspec/target boundaries matter for downstream consumers — adding cross-module dependencies (e.g. Core → TCA) will break Pod consumers even if SwiftPM is happy. New code should respect the existing layering: `Core` depends only on LithoOperators/Slippers/LithoUtils; `TCA` and `ErrorHandlingCombine` build on top.
