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
                    injector.bind("hello", to: NSObject())
                }
            }

            beforeEach {
                subject = Injector(module: SomeModule())
            }

            it("should configure it") {
                expect(subject.create("hello") is NSObject).to(beTruthy())
            }
        }
        
        describe("Creating objects") {
            describe("through classes") {
                describe("Creating objects using standard initializer") {
                    it("Should create an object using the standard init()") {
                        expect(subject.create(NSObject.self) is NSObject).to(beTruthy())
                    }
                    
                    it("Should set the injector property") {
                        if let obj = subject.create(NSObject.self) as? NSObject {
                            expect(obj.injector).to(beIdenticalTo(subject))
                        } else {
                            expect(false).to(beTruthy())
                        }
                    }
                }
                
                describe("Creating objects using a custom initializer") {
                    beforeEach {
                        subject.bind(SomeObject.self, to: SomeObject(object: ()))
                    }
                    
                    it("should use the custom initializer") {
                        expect(subject.create(SomeObject.self) is SomeObject).to(beTruthy())
                    }
                    
                    it("Should set the injector property") {
                        if let obj = subject.create(SomeObject.self) as? SomeObject {
                            expect(obj.injector).to(beIdenticalTo(subject))
                        } else {
                            expect(false).to(beTruthy())
                        }
                    }
                }

                describe("Creating objects conforming to Injectable") {
                    it("should use the init(injector:) initializer") {
                        let obj = subject.create(InjectableObject.self)
                        expect(obj is InjectableObject).to(beTruthy())
                        if let obj = obj as? InjectableObject {
                            expect(obj.wasInjected).to(beTruthy())
                        }
                    }
                }
            }
            
            describe("through strings") {
                it("should return nil if there is not an existing creation method for a string") {
                    expect(subject.create("Sholvah!")).to(beNil())
                }
                
                it("should return an instance of a class if there is an existing creation method for the string") {
                    subject.bind("I die free", to: NSDictionary())
                    
                    if let obj = subject.create("I die free") as? NSDictionary {
                        expect(obj.injector).to(beIdenticalTo(subject))
                    } else {
                        expect(false).to(beTruthy())
                    }
                }

                it("should allow structs and such to be created") {
                    var theStruct = aStruct()
                    subject.bind("Hammond of Texas", to: theStruct)

                    theStruct.someInstance = 20

                    if let str = subject.create("Hammond of Texas") as? aStruct {
                        expect(str.someInstance).to(equal(20))
                    } else {
                        expect(false).to(beTruthy())
                    }
                }
            }
        }
        
        describe("Setting creation methods") {
            context("when given a class") {
                beforeEach {
                    subject.bind(AnObject.self, to: AnObject(object: NSObject()))
                }
                
                it("should set a custom creation method") {
                    expect((subject.create(AnObject.self) as! AnObject).someObject).toNot(beNil())
                    expect((subject.create(AnObject.self) as! AnObject).someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.bind(AnObject.self) {
                        return AnObject(otherObject: NSObject())
                    }
                    expect((subject.create(AnObject.self) as! AnObject).someObject).to(beNil())
                    expect((subject.create(AnObject.self) as! AnObject).someOtherObject).toNot(beNil())
                }
                
                it("should allow the user to delete any existing creation method") {
                    subject.removeBinding(AnObject.self)
                    expect((subject.create(AnObject.self) as! AnObject).someObject).to(beNil())
                    expect((subject.create(AnObject.self) as! AnObject).someOtherObject).to(beNil())
                }

                it("should have no effect when trying to remove an object not registered") {
                    subject.removeBinding(NSObject.self)
                    expect(subject.create(NSObject.self)).toNot(beNil())
                }

                it("should use this method even when the object conforms to Injectable") {
                    let obj = InjectableObject()
                    subject.bind(InjectableObject.self, to: obj)
                    expect((subject.create(InjectableObject.self) as? InjectableObject)?.wasInjected).to(beFalsy())
                }
            }

            context("when given a protocol") {
                beforeEach {
                    subject.bind(aProtocol.self, to: aStruct())
                }

                it("should set the creation method") {
                    expect(subject.create(aProtocol.self) is aStruct).to(beTruthy())
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
                    subject.bind("Indeed") {
                        return AnObject(otherObject: NSObject())
                    }
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
