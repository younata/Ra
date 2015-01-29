import Foundation

public class Injector {
    public init() {}

    public var creationMethods : [String: (Void) -> (NSObject)] = [:]

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
}