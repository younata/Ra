import Foundation

public extension NSObject {
    private struct AssociatedKeys {
        static var injectorKey = "ra_injectorKey"
    }

    public internal(set) var injector : Injector? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.injectorKey) as? Injector
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.injectorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}