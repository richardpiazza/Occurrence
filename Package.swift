// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Occurrence",
    platforms: [
        .macOS(.v13),
        .macCatalyst(.v16),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1), // .v2 ~ iOS 18
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Occurrence",
            targets: ["Occurrence"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/swiftlang/swift-toolchain-sqlite.git", from: "1.0.7"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.9.1"),
        .package(url: "https://github.com/richardpiazza/Statement.git", from: "0.8.1"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.5", traits: ["SwiftToolchainCSQLite"]),
        .package(url: "https://github.com/swhitty/swift-mutex.git", from: "0.0.6"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Occurrence",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Statement", package: "Statement"),
                .product(name: "StatementSQLite", package: "Statement"),
                .product(name: "SQLite", package: "SQLite.swift"),
                .product(name: "Mutex", package: "swift-mutex"),
            ]
        ),
        .testTarget(
            name: "OccurrenceTests",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "Occurrence",
            ]
        ),
    ]
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(contentsOf: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("StrictConcurrency=complete"),
    ])
    target.swiftSettings = settings
}
