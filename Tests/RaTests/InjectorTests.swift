import Foundation
import Nimble
import Quick
import Ra

class SomeObject : NSObject {
    override init() {
        fatalError("Should not happen")
    }
    
    init(object: ()) {
        super.init()
    }
}

class AnObject : NSObject {
    var someObject : NSObject? = nil
    var someOtherObject : NSObject? = nil
    
    init(object: NSObject) {
        self.someObject = object
        super.init()
    }
    
    init(otherObject: NSObject) {
        self.someOtherObject = otherObject
        super.init()
    }
    
    override init() {
        super.init()
    }
}

class InjectableObject : Injectable {
    var wasInjected : Bool = false
    required init(injector: Injector) {
        wasInjected = true
    }

    init() {}
}

class InjectableNSObject : NSObject, Injectable {
    var wasInjector : Bool = false
    required init(injector: Injector) {
        wasInjector = true
        super.init()
    }
}

protocol aProtocol {}

struct aStruct : aProtocol {
    var someInstance : Int = 0
}

class InjectorTests: QuickSpec {
    override func spec() {
        var subject: Injector! = nil

        beforeEach {
            subject = Ra.Injector()
        }

        describe("initting with modules") {
            class SomeModule : InjectorModule {
                func configureInjector(injector: Injector) {
                    injector.bind("hello", to: NSObject())
                }
            }

            beforeEach {
                subject = Injector(module: SomeModule())
            }

            it("should configure it") {
                expect(subject.create("hello") is NSObject) == true
            }
        }
        
        describe("Creating objects") {
            describe("through classes") {
                describe("Creating objects using standard initializer") {
                    it("Should create an object using the standard init()") {
                        expect(subject.create(NSObject.self)).to(beAKindOf(NSObject.self))
                    }
                }
                
                describe("Creating objects using a custom initializer") {
                    beforeEach {
                        subject.bind(SomeObject.self, to: SomeObject(object: ()))
                    }
                    
                    it("should use the custom initializer") {
                        expect(subject.create(SomeObject.self)).to(beAKindOf(SomeObject.self))
                    }
                }

                describe("Creating objects conforming to Injectable") {
                    it("should use the init(injector:) initializer") {
                        let obj = subject.create(InjectableObject.self)
                        expect(obj?.wasInjected) == true
                    }
                }
            }
            
            describe("through strings") {
                it("should return nil if there is not an existing creation method for a string") {
                    expect(subject.create("Sholvah!")).to(beNil())
                }
                
                it("should return an instance of a class if there is an existing creation method for the string") {
                    let initialObject = NSDictionary()
                    subject.bind("I die free", to: initialObject)
                    
                    if let obj = subject.create("I die free") as? NSDictionary {
                        expect(obj).to(beIdenticalTo(initialObject))
                    } else {
                        fail("No")
                    }
                }

                it("should allow structs and such to be created") {
                    subject.bind("Hammond of Texas", to: aStruct())

                    expect(subject.create("Hammond of Texas")).toNot(beNil())

                    var theStruct = aStruct()
                    var receivedInjector: Injector? = nil
                    subject.bind("Hammond of Texas") {
                        receivedInjector = $0
                        return theStruct
                    }

                    theStruct.someInstance = 100

                    expect((subject.create("Hammond of Texas") as? aStruct)?.someInstance) == 100
                    expect(receivedInjector === subject) == true
                }
            }

            it("does not cache created objects unless otherwise specified") {
                expect(subject.create(InjectableObject.self)) !== subject.create(InjectableObject.self)
                expect(subject.create(InjectableNSObject.self)) !== subject.create(InjectableNSObject.self)
                expect(subject.create(NSObject.self)) !== subject.create(NSObject.self)

                subject.bind(NSObject.self, to: NSDictionary())

                expect(subject.create(NSObject.self)) === subject.create(NSObject.self)
            }
        }
        
        describe("Setting creation methods") {
            context("when given a class") {
                beforeEach {
                    subject.bind(AnObject.self, to: AnObject(object: NSObject()))
                }
                
                it("should set a custom creation method") {
                    expect(subject.create(AnObject.self)?.someObject).toNot(beNil())
                    expect(subject.create(AnObject.self)?.someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.bind(AnObject.self) { _ in
                        return AnObject(otherObject: NSObject())
                    }
                    expect(subject.create(AnObject.self)?.someObject).to(beNil())
                    expect(subject.create(AnObject.self)?.someOtherObject).toNot(beNil())
                }
                
                it("should allow the user to delete any existing creation method") {
                    subject.removeBinding(kind: AnObject.self)
                    expect(subject.create(AnObject.self)?.someObject).to(beNil())
                    expect(subject.create(AnObject.self)?.someOtherObject).to(beNil())
                }

                it("should have no effect when trying to remove an object not registered") {
                    subject.removeBinding(kind: NSObject.self)
                    expect(subject.create(NSObject.self)).toNot(beNil())
                }

                it("should use this method even when the object conforms to Injectable") {
                    let obj = InjectableObject()
                    subject.bind(InjectableObject.self, to: obj)
                    expect(subject.create(InjectableObject.self)?.wasInjected) == false
                }
            }

            context("when given a protocol") {
                beforeEach {
                    subject.bind(aProtocol.self, to: aStruct())
                }

                it("should set the creation method") {
                    expect(subject.create(aProtocol.self) is aStruct) == true
                }
            }
            
            context("when given a string") {
                beforeEach {
                    subject.bind("Indeed", to: AnObject(object: NSObject()))
                }
                
                it("should set a custom creation method") {
                    expect((subject.create("Indeed") as! AnObject).someObject).toNot(beNil())
                    expect((subject.create("Indeed") as! AnObject).someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.bind("Indeed", to: AnObject(otherObject: NSObject()))
                    subject.bind("Indeed") { _ in AnObject(otherObject: NSObject()) }
                    expect((subject.create("Indeed") as! AnObject).someObject).to(beNil())
                    expect((subject.create("Indeed") as! AnObject).someOtherObject).toNot(beNil())
                }
                
                it("should allow the user to delete any existing creation method") {
                    subject.removeBinding("Indeed")
                    expect(subject.create("Indeed")).to(beNil())
                }
            }
        }

        describe("somewhat complex cases") {
            class BaseStruct: Injectable {
                required init(injector: Injector) {

                }
            }

            struct DependingStruct: Injectable {
                let baseStruct: BaseStruct?

                init(injector: Injector) {
                    self.baseStruct = injector.create(BaseStruct.self)
                }
            }

            it("creates somewhat complex cases without blowing up") {
                let depending = subject.create(DependingStruct.self)
                expect(depending).toNot(beNil())
                expect(depending?.baseStruct).toNot(beNil())
            }
        }
    }
}
