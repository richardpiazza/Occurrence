# Occurrence

A swift logging library that integrates with [`SwiftLog`](https://github.com/apple/swift-log).

<p>
    <img src="https://github.com/richardpiazza/Occurrence/workflows/Swift/badge.svg?branch=main" />
    <img src="https://img.shields.io/badge/Swift-5.5-orange.svg" />
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
