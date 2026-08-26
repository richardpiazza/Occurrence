#if canImport(FoundationNetworking)
import FoundationNetworking
#else
import Foundation
#endif

extension URLError: LoggableError {}
