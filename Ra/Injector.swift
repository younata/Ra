import Foundation

public class Injector {
    public init() {}

    private var creationMethods : [String: (Void) -> (AnyObject)] = [:]

    public func create(klass: AnyClass) -> AnyObject? {
        if let closure : (Void) -> (AnyObject) = creationMethods[klass.description()] {
            let obj : AnyObject = closure()
            self.setInjectorIfPossible(obj)
            return obj
        }
        if let aClass = klass as? NSObject.Type { // This is ugly, forcing a reliance on NSObject
            let obj = aClass()
            self.setInjectorIfPossible(obj)
            return obj
        }
        return nil
    }

    public func create(str: String) -> AnyObject? {
        let obj: AnyObject? = creationMethods[str]?()
        self.setInjectorIfPossible(obj)
        return obj
    }
    
    private func setInjectorIfPossible(object: AnyObject?) {
        if let obj = object as? NSObject {
            obj.injector = self
        }
    }
    
    // MARK: Adding creation methods
    // TODO: rename "creation method" to something better.

    public func bind(klass: AnyClass, @autoclosure(escaping) to: () -> (AnyObject)) {
        self.creationMethods[klass.description()] = to
    }

    public func bind(string: String, @autoclosure(escaping) to: () -> (AnyObject)) {
        self.creationMethods[string] = to
    }
    
    public func bind(klass: AnyClass, toClosure: (Void) -> (AnyObject)) {
        self.creationMethods[klass.description()] = toClosure
    }
    
    public func bind(string: String, toClosure: (Void) -> (AnyObject)) {
        self.creationMethods[string] = toClosure
    }
    
    public func removeBinding(klass: AnyClass) {
        self.creationMethods.removeValueForKey(klass.description())
    }
    
    public func removeBinding(string: String) {
        self.creationMethods.removeValueForKey(string)
    }
}
