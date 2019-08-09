// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LocalizedGenStrings",
    dependencies: [
        .package(url: "https://github.com/tuist/xcodeproj.git", .upToNextMajor(from: "7.0.0")),
        .package(url: "https://github.com/kylef/Commander.git", from: "0.9.0"),
        .package(url: "https://github.com/IBDecodable/IBDecodable.git", from: "0.0.4")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "LocalizedGenStrings",
            dependencies: ["LocalizedGenStringsCore"]),
        .target(
            name: "LocalizedGenStringsCore",
            dependencies: ["XcodeProj", "Commander", "IBDecodable"]),
        .testTarget(
            name: "LocalizedGenStringsTests",
            dependencies: ["LocalizedGenStrings"]),
    ]
)
