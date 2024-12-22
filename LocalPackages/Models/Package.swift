// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Models",
            targets: ["Models"])
    ],
    dependencies: [
        .package(url: "https://github.com/lukacs-m/OneTimePassword", branch: "develop"),
        .package(url: "https://github.com/WilhelmOks/ModifiedCopyMacro", .upToNextMajor(from: "2.1.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Models",
            dependencies: [
                .product(name: "ModifiedCopy", package: "ModifiedCopyMacro"),
                .product(name: "OneTimePassword", package: "OneTimePassword")
            ]
        ),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["Models"]
        )
    ]
)
