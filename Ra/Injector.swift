import Foundation

public class Injector {
    public init() {}

    private var creationMethods : [String: (Void) -> (AnyObject)] = [:]

    public func create(obj: Any) -> AnyObject? {
        if let klass: AnyClass = obj as? AnyClass {
            return create(klass)
        } else if let str = obj as? String {
            return create(str)
        }
        return nil
    }

    private func create(klass: AnyClass) -> AnyObject? {
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

    private func create(str: String) -> AnyObject? {
        let obj: AnyObject? = creationMethods[str]?()
        self.setInjectorIfPossible(obj)
        return obj
    }
    
    private func setInjectorIfPossible(object: AnyObject?) {
        if let obj = object as? NSObject {
            obj.injector = self
        }
    }
    
    // MARK: Adding bindings

    public func bind(obj: Any, @autoclosure(escaping) to: () -> (AnyObject)) {
        if let klass: AnyClass = obj as? AnyClass {
            bind(klass, to: to)
        } else if let str = obj as? String {
            bind(str, to: to)
        }
    }

    private func bind(klass: AnyClass, @autoclosure(escaping) to: () -> (AnyObject)) {
        self.creationMethods[klass.description()] = to
    }

    private func bind(string: String, @autoclosure(escaping) to: () -> (AnyObject)) {
        self.creationMethods[string] = to
    }

    public func bind(obj: Any, toClosure: (Void) -> (AnyObject)) {
        if let klass: AnyClass = obj as? AnyClass {
            bind(klass, toClosure: toClosure)
        } else if let str = obj as? String {
            bind(str, toClosure: toClosure)
        }
    }

    private func bind(klass: AnyClass, toClosure: (Void) -> (AnyObject)) {
        self.creationMethods[klass.description()] = toClosure
    }
    
    private func bind(string: String, toClosure: (Void) -> (AnyObject)) {
        self.creationMethods[string] = toClosure
    }

    public func removeBinding(obj: Any) {
        if let klass: AnyClass = obj as? AnyClass {
            removeBinding(klass)
        } else if let str = obj as? String {
            removeBinding(str)
        }
    }
    
    private func removeBinding(klass: AnyClass) {
        self.creationMethods.removeValueForKey(klass.description())
    }
    
    private func removeBinding(string: String) {
        self.creationMethods.removeValueForKey(string)
    }
}
