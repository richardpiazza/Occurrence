// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Occurrence",
    platforms: [
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
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
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.4.2")),
        .package(name: "PerfectSQLite", url: "https://github.com/richardpiazza/Perfect-SQLite", .upToNextMajor(from: "5.1.1")),
        .package(url: "https://github.com/richardpiazza/Statement.git", .branch("feature/hex-data"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Occurrence",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "Statement",
                .product(name: "StatementSQLite", package: "Statement"),
                "PerfectSQLite"
            ]
        ),
        .testTarget(
            name: "OccurrenceTests",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "Occurrence"
            ]
        ),
    ]
)
