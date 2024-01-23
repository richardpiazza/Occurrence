import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLError: CustomMetadataError {
    public var description: String { localizedDescription }
}
