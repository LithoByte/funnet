// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if canImport(Core)
    import Core
#endif

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
            targets: ["FunNetCombine"]),
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
            dependencies: ["LithoOperators",
                            .productItem(name: "LithoUtils",
                                         package: "LithoUtils/Post13",
                                         condition: nil),
                           "Slippers",
                           "ReactiveSwift",
                           .targetItem(name: "Core", condition: nil),
                           .targetItem(name: "FunNetCombine", condition: nil),
                           .targetItem(name: "FunNetReactiveSwift", condition: nil),
                           .targetItem(name: "Multipart", condition: nil),
                           .targetItem(name: "ErrorHandling", condition: nil),
                           .targetItem(name: "ErrorHandlingCombine", condition: nil)],
            path: nil
        ),
        .target(
            name: "Core",
            dependencies: ["LithoOperators", "Slippers"],
            path: "Sources/funnet/Core"
        ),
        .target(
            name: "FunNetCombine",
            dependencies: [.targetItem(name: "Core", condition: nil), "Slippers"],
            path: "Sources/funnet/Combine"
        ),
        .target(
            name: "FunNetReactiveSwift",
            dependencies: [.targetItem(name: "Core", condition: nil), "ReactiveSwift"],
            path: "Sources/funnet/ReactiveSwift"
        ),
        .target(
            name: "Multipart",
            dependencies: ["LithoOperators", .targetItem(name: "Core", condition: nil)],
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
