// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Swat",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Swat",
            targets: ["Swat"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Swat",
            dependencies: ["Yams"],
            path: "Sources/swat"
        ),
        .testTarget(
            name: "SwatTests",
            dependencies: ["Swat"],
            path: "Tests/swatTests"
        ),
    ]
)
