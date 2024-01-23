import Foundation

extension CocoaError: CustomMetadataError {
    public var description: String { localizedDescription }
}
