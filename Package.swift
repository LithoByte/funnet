// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FunNet",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "FunNet",
            targets: ["FunNet"]),
        .library(
            name: "FunNet/Core",
            targets: ["Core"]),
        .library(
            name: "FunNet/Combine",
            targets: ["Combine"]),
        .library(
            name: "FunNet/ReactiveSwift",
            targets: ["FunNetReactiveSwift"]),
        .library(
            name: "FunNet/Multipart",
            targets: ["Multipart"]),
        .library(
            name: "FunNet/ErrorHandling",
            targets: ["ErrorHandling"]),
        .library(
            name: "FunNet/ErrorHandlingCombine",
            targets: ["ErrorHandlingCombine"])
    ],
    dependencies: [
        .package(url: "https://github.com/LithoByte/LithoOperators.git", .branch("master")),
        .package(name: "Slippers", url: "https://github.com/LithoByte/slippers", .branch("cjc8/spm")),
        .package(name: "LithoUtils/Post13", url: "https://github.com/LithoByte/litho-utils", .branch("cjc8/spm")),
        .package(url: "https://github.com/Moya/ReactiveSwift.git", .branch("master"))
    ],
    targets: [
        .target(
            name: "FunNet",
            dependencies: ["LithoOperators", .productItem(name: "LithoUtils", package: "LithoUtils/Post13", condition: nil), "Slippers", "ReactiveSwift"],
            path: "Sources/funnet"
        ),
        .target(
            name: "Core",
            dependencies: ["LithoOperators", "Slippers"],
            path: "Sources/funnet/Core"
        ),
        .target(
            name: "Combine",
            dependencies: [.targetItem(name: "Core", condition: nil)],
            path: "Sources/funnet/Combine"
        ),
        .target(
            name: "FunNetReactiveSwift",
            dependencies: [.targetItem(name: "Core", condition: nil), "ReactiveSwift"],
            path: "Sources/funnet/ReactiveSwift"
        ),
        .target(
            name: "Multipart",
            dependencies: ["LithoOperators"],
            path: "Sources/funnet/Multipart"
        ),
        .target(
            name: "ErrorHandling",
            dependencies: ["LithoOperators", .productItem(name: "LithoUtils", package: "LithoUtils/Post13", condition: nil), "Slippers"],
            path: "Sources/funnet/ErrorHandling"
        ),
        .target(
            name: "ErrorHandlingCombine",
            dependencies: [.targetItem(name: "ErrorHandling", condition: nil), "LithoOperators", "Slippers", .productItem(name: "LithoUtils", package: "LithoUtils/Post13", condition: nil)],
            path: "Sources/funnet/ErrorHandlingCombine"
        ),
    ]
)
