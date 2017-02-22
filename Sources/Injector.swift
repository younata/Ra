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
            module.configureInjector(injector: self)
        }
    }

    private var creationMethods : [String: (Injector) -> (Any)] = [:]

    public func create<T>(_ key: T.Type) -> T? {
        if let klass: AnyClass = key as? AnyClass {
            return create(class: klass) as? T
        } else if let type = key as? Injectable.Type {
            let obj = type.init(injector: self)
            return obj as? T
        } else {
            let mirror = Mirror(reflecting: key)
            return create(mirror.description) as? T
        }
    }

    public func create(_ key: String) -> Any? {
        let obj: Any? = creationMethods[key]?(self)
        return obj
    }

    public func create<T>(_ key: String, type: T.Type) -> T? {
        return self.create(key) as? T
    }

    private func create(class klass: AnyClass) -> Any? {
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

    public func bind<T>(_ obj: T.Type, toBlock to: @escaping (Injector) -> (T)) {
        if let klass: AnyClass = obj as? AnyClass {
            self.bind(class: klass, toBlock: to)
        } else {
            let mirror = Mirror(reflecting: obj)
            self.bind(mirror.description, toBlock: to)
        }
    }

    public func bind(_ string: String, toBlock to: @escaping (Injector) -> (Any)) {
        self.creationMethods[string] = to
    }

    private func bind(class klass: AnyClass, toBlock to: @escaping (Injector) -> (Any)) {
        self.creationMethods[klass.description()] = to
    }

    public func bind<T>(_ obj: T.Type, to: T) {
        if let klass: AnyClass = obj as? AnyClass {
            self.bind(class: klass, toBlock: {_ in to})
        } else {
            let mirror = Mirror(reflecting: obj)
            self.bind(mirror.description, toBlock: {_ in to})
        }
    }

    public func bind(_ string: String, to: Any) {
        self.bind(string, toBlock: {_ in to})
    }

    public func removeBinding(_ obj: Any) {
        if let klass: AnyClass = obj as? AnyClass {
            self.removeBinding(class: klass)
        } else if let str = obj as? String {
            self.removeBinding(string: str)
        } else {
            let mirror = Mirror(reflecting: obj)
            self.removeBinding(string: mirror.description)
        }
    }
    
    private func removeBinding(class klass: AnyClass) {
        self.creationMethods.removeValue(forKey: klass.description())
    }
    
    private func removeBinding(string: String) {
        self.creationMethods.removeValue(forKey: string)
    }
}
