# Occurrence

A swift logging library that integrates with [`SwiftLog`](https://github.com/apple/swift-log).

<p>
    <img src="https://github.com/richardpiazza/Occurrence/workflows/Swift/badge.svg?branch=main" />
    <img src="https://img.shields.io/badge/Swift-5.3-orange.svg" />
    <a href="https://twitter.com/richardpiazza">
        <img src="https://img.shields.io/badge/twitter-@richardpiazza-blue.svg?style=flat" alt="Twitter: @richardpiazza" />
    </a>
</p>

## Installation

**Occurrence** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, Use the 
Xcode 'Swift Packages' menu or add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/Occurence.git", .upToNextMinor(from: "0.3.0"))
    ],
    ...
)
```

Then import the **Occurrence** packages wherever you'd like to use it:

```swift
import Occurrence
```

## Usage

During you app initialization, call `Occurrence.bootstrap()`. This will configure the Swift `LoggingSystem` to use **Occurrence** as a `LogHandler`.

As a convenience to creating a `Logger` reference, use the `LazyLogger` property wrapper which will create a Logger with the specific label (`Logger.Subsystem`).
```swift
@LazyLogger("LoggerLabel") var logger: Logger
```
