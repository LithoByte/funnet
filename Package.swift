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
            targets: ["FunNetCore"]),
        .library(
            name: "FunNet/TCA",
            targets: ["FunNetTCA"]),
        .library(
            name: "FunNet/Multipart",
            targets: ["FunNetMultipart"]),
        .library(
            name: "FunNet/ErrorHandling",
            targets: ["ErrorHandling"]),
        .library(
            name: "FunNet/ErrorHandlingCombine",
            targets: ["ErrorHandlingCombine"])
    ],
    dependencies: [
        .package(name: "swift-composable-architecture", url: "https://github.com/pointfreeco/swift-composable-architecture", .branch("observation-beta")),
        .package(url: "https://github.com/LithoByte/LithoOperators.git", .branch("master")),
        .package(name: "Slippers", url: "https://github.com/LithoByte/slippers", .branch("cjc8/spm")),
        .package(name: "LithoUtils/Post13", url: "https://github.com/LithoByte/litho-utils", .branch("cjc8/spm"))
    ],
    targets: [
        .target(
            name: "FunNet",
            dependencies: ["LithoOperators",
                            .productItem(name: "LithoUtils",
                                         package: "LithoUtils/Post13",
                                         condition: nil),
                           "Slippers",
                           .targetItem(name: "FunNetCore", condition: nil),
                           .targetItem(name: "FunNetMultipart", condition: nil),
                           .targetItem(name: "ErrorHandling", condition: nil),
                           .targetItem(name: "ErrorHandlingCombine", condition: nil)],
            path: nil
        ),
        .target(
            name: "FunNetCore",
            dependencies: ["LithoOperators", "Slippers"],
            path: "Sources/funnet/Core"
        ),
        .target(
            name: "FunNetTCA",
            dependencies: [.product(name: "ComposableArchitecture", package: "swift-composable-architecture"), .targetItem(name: "FunNetCore", condition: nil)],
            path: "Sources/funnet/TCA"
        ),
        .target(
            name: "FunNetMultipart",
            dependencies: ["LithoOperators", .targetItem(name: "FunNetCore", condition: nil)],
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
