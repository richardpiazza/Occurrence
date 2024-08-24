import Foundation
#if canImport(CoreData)
@preconcurrency import CoreData

public final class LogModel: Sendable {
    
    private let _managedObjectModel: NSManagedObjectModel
    
    init(model: @Sendable () -> NSManagedObjectModel) {
        _managedObjectModel = model()
    }
    
    public func managedObjectModel() -> NSManagedObjectModel {
        _managedObjectModel
    }
    
    /// Provide a singular instance of the model to be referenced. There is a known issue where when referencing
    /// a model in multiple targets can fatally be loaded twice.
    public static let version_1_0_0 = LogModel(model: { Version_1_0_0() })
}

final class Version_1_0_0: NSManagedObjectModel, NSSecureCoding {
    
    static var supportsSecureCoding: Bool { true }

    override init() {
        super.init()

        // Attributes
        let date = NSAttributeDescription()
        date.name = "date"
        date.attributeType = .dateAttributeType
        date.isOptional = false
        date.defaultValue = nil

        let subsystem = NSAttributeDescription()
        subsystem.name = "subsystem"
        subsystem.attributeType = .stringAttributeType
        subsystem.isOptional = false
        subsystem.defaultValue = ""

        let level = NSAttributeDescription()
        level.name = "level"
        level.attributeType = .stringAttributeType
        level.isOptional = false
        level.defaultValue = ""

        let message = NSAttributeDescription()
        message.name = "message"
        message.attributeType = .stringAttributeType
        message.isOptional = false
        message.defaultValue = ""

        let metadata = NSAttributeDescription()
        metadata.name = "metadata"
        metadata.attributeType = .binaryDataAttributeType
        metadata.isOptional = true
        message.defaultValue = nil

        let source = NSAttributeDescription()
        source.name = "source"
        source.attributeType = .stringAttributeType
        source.isOptional = false
        source.defaultValue = ""

        let file = NSAttributeDescription()
        file.name = "file"
        file.attributeType = .stringAttributeType
        file.isOptional = false
        file.defaultValue = ""

        let function = NSAttributeDescription()
        function.name = "function"
        function.attributeType = .stringAttributeType
        function.isOptional = false
        function.defaultValue = ""

        let line = NSAttributeDescription()
        line.name = "line"
        line.attributeType = .integer64AttributeType
        line.isOptional = false
        line.defaultValue = 0

        // Entities

        let entry = NSEntityDescription()
        entry.name = "ManagedEntry"
        entry.managedObjectClassName = "ManagedEntry"
        entry.properties = [date, subsystem, level, message, metadata, source, file, function, line]

        entities = [entry]
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
