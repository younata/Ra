//
//  NSObject+Ra.swift
//  Ra
//
//  Created by Rachel Brindle on 2/20/15.
//  Copyright (c) 2015 Rachel Brindle. All rights reserved.
//

import Foundation

var AssociatedObjectHandle = 0x1234567890

public extension NSObject {
    public internal(set) var injector : Injector? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as Injector?
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_ASSIGN))
        }
    }
}