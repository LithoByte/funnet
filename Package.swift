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
            dependencies: ["LithoOperators", .productItem(name: "LithoUtils", package: "LithoUtils/Post13", condition: nil), "Slippers", "ReactiveSwift"]),
    ]
)
