// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataLayer",
    platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DataLayer",
            targets: ["DataLayer"])
    ],
    dependencies: [
        .package(url: "https://github.com/lukacs-m/SimplyPersist", branch: "main"),
        .package(name: "Models", path: "../Models")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataLayer",
            dependencies: [
                .product(name: "SimplyPersist", package: "SimplyPersist"),
                .product(name: "Models", package: "Models")
            ]),
        .testTarget(
            name: "DataLayerTests",
            dependencies: ["DataLayer"]
        )
    ]
)
