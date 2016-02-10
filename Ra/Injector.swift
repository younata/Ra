import Foundation

public protocol Injectable {
    init(injector: Injector)
}

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

    private var creationMethods : [String: (Injector) -> (Any)] = [:]

    public func create<T>(key: T.Type) -> T? {
        if let klass: AnyClass = key as? AnyClass {
            return create(klass) as? T
        } else {
            let mirror = Mirror(reflecting: key)
            return create(mirror.description) as? T
        }
    }

    public func create(key: String) -> Any? {
        let obj: Any? = creationMethods[key]?(self)
        return obj
    }

    private func create(klass: AnyClass) -> Any? {
        if let closure : (Injector) -> (Any) = creationMethods[klass.description()] {
            let obj : Any = closure(self)
            return obj
        }
        if let inj = klass as? Injectable.Type {
            let obj = inj.init(injector: self)
            return obj
        }
        if let aClass = klass as? NSObject.Type {
            let obj = aClass.init()
            return obj
        }
        return nil
    }
    
    // MARK: Adding bindings

    public func bind<T>(obj: T.Type, to: (Injector) -> (T)) {
        if let klass: AnyClass = obj as? AnyClass {
            self.bind(klass, to: to)
        } else {
            let mirror = Mirror(reflecting: obj)
            self.bind(mirror.description, to: to)
        }
    }

    public func bind(string: String, to: (Injector) -> (Any)) {
        self.creationMethods[string] = to
    }

    private func bind(klass: AnyClass, to: (Injector) -> (Any)) {
        self.creationMethods[klass.description()] = to
    }

    public func bind<T>(obj: T.Type, toInstance: T) {
        if let klass: AnyClass = obj as? AnyClass {
            self.bind(klass, to: {_ in toInstance})
        } else {
            let mirror = Mirror(reflecting: obj)
            self.bind(mirror.description, to: {_ in toInstance})
        }
    }

    public func bind(string: String, toInstance: Any) {
        self.bind(string, to: {_ in toInstance})
    }

    public func removeBinding(obj: Any) {
        if let klass: AnyClass = obj as? AnyClass {
            self.removeBinding(klass)
        } else if let str = obj as? String {
            self.removeBinding(str)
        } else {
            let mirror = Mirror(reflecting: obj)
            self.removeBinding(mirror.description)
        }
    }
    
    private func removeBinding(klass: AnyClass) {
        self.creationMethods.removeValueForKey(klass.description())
    }
    
    private func removeBinding(string: String) {
        self.creationMethods.removeValueForKey(string)
    }
}
