import Foundation
#if canImport(CoreData)
import CoreData

enum LogModel {
    case version_1_0_0
    
    static var `default`: LogModel = .version_1_0_0
    
    var managedObjectModel: NSManagedObjectModel {
        switch self {
        case .version_1_0_0: return Version_1_0_0.instance
        }
    }
}

private class Version_1_0_0: NSManagedObjectModel {
    /// Provide a singular instance of the model to be referenced. There is a known issue where when referencing
    /// a model in an app target, as well as unit tests, a model - and therefore its entities - can be loaded twice.
    public static let instance: Version_1_0_0 = Version_1_0_0()

    private override init() {
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
#endif
