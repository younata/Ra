import Foundation

public protocol InjectorModule {
    func configureInjector(injector: Injector)
}

public class Injector {
    public init() {}

    public convenience init(module: InjectorModule...) {
        self.init()
        for module in module {
            module.configureInjector(self)
        }
    }

    private var creationMethods : [String: (Void) -> (Any)] = [:]

    public func create(obj: Any) -> Any? {
        if let klass: AnyClass = obj as? AnyClass {
            return create(klass)
        } else if let str = obj as? String {
            return create(str)
        }
        return nil
    }

    private func create(klass: AnyClass) -> Any? {
        if let closure : (Void) -> (Any) = creationMethods[klass.description()] {
            let obj : Any = closure()
            self.setInjectorIfPossible(obj)
            return obj
        }
        if let aClass = klass as? NSObject.Type {
            let obj = aClass()
            self.setInjectorIfPossible(obj)
            return obj
        }
        return nil
    }

    private func create(str: String) -> Any? {
        let obj: Any? = creationMethods[str]?()
        self.setInjectorIfPossible(obj)
        return obj
    }
    
    private func setInjectorIfPossible(object: Any?) {
        if let obj = object as? NSObject {
            obj.injector = self
        }
    }
    
    // MARK: Adding bindings

    public func bind(obj: Any, @autoclosure(escaping) to: () -> (Any)) {
        if let klass: AnyClass = obj as? AnyClass {
            bind(klass, to: to)
        } else if let str = obj as? String {
            bind(str, to: to)
        }
    }

    private func bind(klass: AnyClass, @autoclosure(escaping) to: () -> (Any)) {
        self.creationMethods[klass.description()] = to
    }

    private func bind(string: String, @autoclosure(escaping) to: () -> (Any)) {
        self.creationMethods[string] = to
    }

    public func bind(obj: Any, toClosure: (Void) -> (Any)) {
        if let klass: AnyClass = obj as? AnyClass {
            bind(klass, toClosure: toClosure)
        } else if let str = obj as? String {
            bind(str, toClosure: toClosure)
        }
    }

    private func bind(klass: AnyClass, toClosure: (Void) -> (Any)) {
        self.creationMethods[klass.description()] = toClosure
    }
    
    private func bind(string: String, toClosure: (Void) -> (Any)) {
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
