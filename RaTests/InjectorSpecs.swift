import Quick
import Nimble
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

protocol aProtocol {}

struct aStruct : aProtocol {
    var someInstance : Int = 0
}

class InjectorSpec: QuickSpec {
    override func spec() {
        var subject : Injector! = nil

        beforeEach {
            subject = Ra.Injector()
        }

        describe("initting with modules") {
            class SomeModule : InjectorModule {
                func configureInjector(injector: Injector) {
                    injector.bind("hello", toInstance: NSObject())
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
                        expect(subject.create(NSObject)).to(beAKindOf(NSObject))
                    }
                }
                
                describe("Creating objects using a custom initializer") {
                    beforeEach {
                        subject.bind(SomeObject.self, toInstance: SomeObject(object: ()))
                    }
                    
                    it("should use the custom initializer") {
                        expect(subject.create(SomeObject)).to(beAKindOf(SomeObject))
                    }
                }

                describe("Creating objects conforming to Injectable") {
                    it("should use the init(injector:) initializer") {
                        let obj = subject.create(InjectableObject)
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
                    subject.bind("I die free", toInstance: initialObject)
                    
                    if let obj = subject.create("I die free") as? NSDictionary {
                        expect(obj).to(beIdenticalTo(initialObject))
                    } else {
                        fail("No")
                    }
                }

                it("should allow structs and such to be created") {
                    subject.bind("Hammond of Texas", toInstance: aStruct())

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
        }
        
        describe("Setting creation methods") {
            context("when given a class") {
                beforeEach {
                    subject.bind(AnObject.self, toInstance: AnObject(object: NSObject()))
                }
                
                it("should set a custom creation method") {
                    expect(subject.create(AnObject)?.someObject).toNot(beNil())
                    expect(subject.create(AnObject)?.someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.bind(AnObject.self) { _ in
                        return AnObject(otherObject: NSObject())
                    }
                    expect(subject.create(AnObject)?.someObject).to(beNil())
                    expect(subject.create(AnObject)?.someOtherObject).toNot(beNil())
                }
                
                it("should allow the user to delete any existing creation method") {
                    subject.removeBinding(AnObject)
                    expect(subject.create(AnObject)?.someObject).to(beNil())
                    expect(subject.create(AnObject)?.someOtherObject).to(beNil())
                }

                it("should have no effect when trying to remove an object not registered") {
                    subject.removeBinding(NSObject)
                    expect(subject.create(NSObject)).toNot(beNil())
                }

                it("should use this method even when the object conforms to Injectable") {
                    let obj = InjectableObject()
                    subject.bind(InjectableObject.self, toInstance: obj)
                    expect(subject.create(InjectableObject.self)?.wasInjected) == false
                }
            }

            context("when given a protocol") {
                beforeEach {
                    subject.bind(aProtocol.self, toInstance: aStruct())
                }

                it("should set the creation method") {
                    expect(subject.create(aProtocol.self) is aStruct) == true
                }
            }
            
            context("when given a string") {
                beforeEach {
                    subject.bind("Indeed", toInstance: AnObject(object: NSObject()))
                }
                
                it("should set a custom creation method") {
                    expect((subject.create("Indeed") as! AnObject).someObject).toNot(beNil())
                    expect((subject.create("Indeed") as! AnObject).someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.bind("Indeed", toInstance: AnObject(otherObject: NSObject()))
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
    }
}
