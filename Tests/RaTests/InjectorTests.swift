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
        var subject : Injector! = nil

        beforeEach {
            subject = Ra.Injector()
        }

        describe("initting with modules") {
            class SomeModule : InjectorModule {
                func configureInjector(injector: Injector) {
                    injector.bind(string: "hello", toInstance: NSObject())
                }
            }

            beforeEach {
                subject = Injector(module: SomeModule())
            }

            it("should configure it") {
                expect(subject.create(string: "hello") is NSObject) == true
            }
        }
        
        describe("Creating objects") {
            describe("through classes") {
                describe("Creating objects using standard initializer") {
                    it("Should create an object using the standard init()") {
                        expect(subject.create(kind: NSObject.self)).to(beAKindOf(NSObject.self))
                    }
                }
                
                describe("Creating objects using a custom initializer") {
                    beforeEach {
                        subject.bind(kind: SomeObject.self, toInstance: SomeObject(object: ()))
                    }
                    
                    it("should use the custom initializer") {
                        expect(subject.create(kind: SomeObject.self)).to(beAKindOf(SomeObject.self))
                    }
                }

                describe("Creating objects conforming to Injectable") {
                    it("should use the init(injector:) initializer") {
                        let obj = subject.create(kind: InjectableObject.self)
                        expect(obj?.wasInjected) == true
                    }
                }
            }
            
            describe("through strings") {
                it("should return nil if there is not an existing creation method for a string") {
                    expect(subject.create(string: "Sholvah!")).to(beNil())
                }
                
                it("should return an instance of a class if there is an existing creation method for the string") {
                    let initialObject = NSDictionary()
                    subject.bind(string: "I die free", toInstance: initialObject)
                    
                    if let obj = subject.create(string: "I die free") as? NSDictionary {
                        expect(obj).to(beIdenticalTo(initialObject))
                    } else {
                        fail("No")
                    }
                }

                it("should allow structs and such to be created") {
                    subject.bind(string: "Hammond of Texas", toInstance: aStruct())

                    expect(subject.create(string: "Hammond of Texas")).toNot(beNil())

                    var theStruct = aStruct()
                    var receivedInjector: Injector? = nil
                    subject.bind(string: "Hammond of Texas") {
                        receivedInjector = $0
                        return theStruct
                    }

                    theStruct.someInstance = 100

                    expect((subject.create(string: "Hammond of Texas") as? aStruct)?.someInstance) == 100
                    expect(receivedInjector === subject) == true
                }
            }

            it("does not cache created objects unless otherwise specified") {
                expect(subject.create(kind: InjectableObject.self)) !== subject.create(kind: InjectableObject.self)
                expect(subject.create(kind: InjectableNSObject.self)) !== subject.create(kind: InjectableNSObject.self)
                expect(subject.create(kind: NSObject.self)) !== subject.create(kind: NSObject.self)

                subject.bind(kind: NSObject.self, toInstance: NSDictionary())

                expect(subject.create(kind: NSObject.self)) === subject.create(kind: NSObject.self)
            }
        }
        
        describe("Setting creation methods") {
            context("when given a class") {
                beforeEach {
                    subject.bind(kind: AnObject.self, toInstance: AnObject(object: NSObject()))
                }
                
                it("should set a custom creation method") {
                    expect(subject.create(kind: AnObject.self)?.someObject).toNot(beNil())
                    expect(subject.create(kind: AnObject.self)?.someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.bind(kind: AnObject.self) { _ in
                        return AnObject(otherObject: NSObject())
                    }
                    expect(subject.create(kind: AnObject.self)?.someObject).to(beNil())
                    expect(subject.create(kind: AnObject.self)?.someOtherObject).toNot(beNil())
                }
                
                it("should allow the user to delete any existing creation method") {
                    subject.removeBinding(kind: AnObject.self)
                    expect(subject.create(kind: AnObject.self)?.someObject).to(beNil())
                    expect(subject.create(kind: AnObject.self)?.someOtherObject).to(beNil())
                }

                it("should have no effect when trying to remove an object not registered") {
                    subject.removeBinding(kind: NSObject.self)
                    expect(subject.create(kind: NSObject.self)).toNot(beNil())
                }

                it("should use this method even when the object conforms to Injectable") {
                    let obj = InjectableObject()
                    subject.bind(kind: InjectableObject.self, toInstance: obj)
                    expect(subject.create(kind: InjectableObject.self)?.wasInjected) == false
                }
            }

            context("when given a protocol") {
                beforeEach {
                    subject.bind(kind: aProtocol.self, toInstance: aStruct())
                }

                it("should set the creation method") {
                    expect(subject.create(kind: aProtocol.self) is aStruct) == true
                }
            }
            
            context("when given a string") {
                beforeEach {
                    subject.bind(string: "Indeed", toInstance: AnObject(object: NSObject()))
                }
                
                it("should set a custom creation method") {
                    expect((subject.create(string: "Indeed") as! AnObject).someObject).toNot(beNil())
                    expect((subject.create(string: "Indeed") as! AnObject).someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.bind(string: "Indeed", toInstance: AnObject(otherObject: NSObject()))
                    subject.bind(string: "Indeed") { _ in AnObject(otherObject: NSObject()) }
                    expect((subject.create(string: "Indeed") as! AnObject).someObject).to(beNil())
                    expect((subject.create(string: "Indeed") as! AnObject).someOtherObject).toNot(beNil())
                }
                
                it("should allow the user to delete any existing creation method") {
                    subject.removeBinding("Indeed")
                    expect(subject.create(string: "Indeed")).to(beNil())
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
                    self.baseStruct = injector.create(kind: BaseStruct.self)
                }
            }

            it("creates somewhat complex cases without blowing up") {
                let depending = subject.create(kind: DependingStruct.self)
                expect(depending).toNot(beNil())
                expect(depending?.baseStruct).toNot(beNil())
            }
        }
    }
}
