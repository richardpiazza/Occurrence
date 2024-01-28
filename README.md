# Occurrence

A swift logging library that integrates with [`SwiftLog`](https://github.com/apple/swift-log).

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FOccurrence%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/richardpiazza/Occurrence)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FOccurrence%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/richardpiazza/Occurrence)

## Installation

**Occurrence** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, Use the 
Xcode 'Swift Packages' menu or add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/Occurence.git", .upToNextMinor(from: "0.6.0"))
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

**Occurrence** also offers the ability to observe logging events as they are happening.
This can also be useful in the case where entries may need to be proxied to a third-party service.

```swift
// Combine
Occurrence.logStreamer
    .publisher
    .sink { entry in
        // process entry
    }

// async/await
let task = Task {
    for await entry in Occurrence.logStreamer.stream {
        // process entry
    }
}
```

### Conveniences

**Occurrence** has many conveniences to enhance the overall logging experience.

The `LoggableError` protocol provides a way to easily convert errors to a `Logger.Metadata` representation.
There are also extensions to the `Logger` instance that allow for passthrough of a `LoggableError` instance:

```swift
@LazyLogger("MyApp") var logger: Logger

enum AppError: LoggableError {
  case badData
}

func throwingFunction() throws {
  guard condition else {
    throw logger.error("Condition not met.", AppError.badData)
  }
}
```
