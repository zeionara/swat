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
        .executable(
            name: "Examples",
            targets: ["Examples"]
        )
    ],
    dependencies: [
        // .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1"),
        .package(url: "https://github.com/zeionara/Yams.git", branch: "main"),
        .package(url: "https://github.com/zeionara/YamlSwift.git", branch: "master"),
        .package(url: "https://github.com/wickwirew/Runtime.git", branch: "master")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Swat",
            dependencies: [
                "Yams",
                .product(name: "Yaml", package: "YamlSwift"),
                "Runtime"
            ],
            path: "Sources/swat"
        ),
        .executableTarget(
            name: "Examples",
            dependencies: [
                "Swat"
            ],
            path: "Examples"
        ),
        .testTarget(
            name: "SwatTests",
            dependencies: ["Swat"],
            path: "Tests/swatTests"
        )
    ]
)
