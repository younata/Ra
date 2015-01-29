import Foundation

public class Injector {
    public init() {}

    private var creationMethods : [String: (Void) -> (NSObject)] = [:]

    public func create(klass: AnyClass) -> NSObject {
        if let closure : (Void) -> (NSObject) = creationMethods[klass.description()] {
            return closure()
        }
        let aClass = (klass as NSObject.Type) // This is ugly, forcing a reliance on NSObject

        return aClass()
    }

    public func create(str: String) -> NSObject? {
        return creationMethods[str]?()
    }
    
    // MARK: Adding creation methods
    // TODO: rename "creation method" to something better.
    
    public func setCreationMethod(klass: AnyClass, creationMethod: (Void) -> (NSObject)) {
        self.creationMethods[klass.description()] = creationMethod
    }
    
    public func setCreationMethod(string: String, creationMethod: (Void) -> (NSObject)) {
        self.creationMethods[string] = creationMethod
    }
    
    public func removeCreationMethod(klass: AnyClass) {
        self.creationMethods.removeValueForKey(klass.description())
    }
    
    public func removeCreationMethod(string: String) {
        self.creationMethods.removeValueForKey(string)
    }
}