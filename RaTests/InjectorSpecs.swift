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

class InjectorSpec: QuickSpec {
    override func spec() {
        var subject : Injector! = nil

        beforeEach {
            subject = Ra.Injector()
        }
        
        describe("Creating objects") {
            describe("through classes") {
                describe("Creating objects using standard initializer") {
                    it("Should create an object using the standard init()") {
                        expect(subject.create(NSObject.self)).to(beAnInstanceOf(NSObject.self))
                    }
                    
                    it("Should set the injector property") {
                        let obj = subject.create(NSObject.self)
                        expect(obj.injector).to(beIdenticalTo(subject))
                    }
                }
                
                describe("Creating objects using a custom initializer") {
                    beforeEach {
                        subject.setCreationMethod(SomeObject.self) {
                            return SomeObject(object: ())
                        }
                    }
                    
                    it("should use the custom initializer") {
                        expect(subject.create(SomeObject.self)).to(beAnInstanceOf(SomeObject.self))
                    }
                    
                    it("Should set the injector property") {
                        let obj = subject.create(SomeObject.self)
                        expect(obj.injector).to(beIdenticalTo(subject))
                    }
                }
            }
            
            describe("through strings") {
                it("should return nil if there is not an existing creation method for a string") {
                    expect(subject.create("Sholvah!")).to(beNil())
                }
                
                it("should return an instance of a class if there is an existing creation method for the string") {
                    subject.setCreationMethod("I die free") {
                        return NSDictionary()
                    }
                    
                    if let obj = subject.create("I die free") {
                        expect(obj.injector).to(beIdenticalTo(subject))
                        expect(obj).to(beAKindOf(NSDictionary.self))
                    } else {
                        expect(false).to(beTruthy())
                    }
                }
            }
        }
        
        describe("Setting creation methods") {
            context("when given a class") {
                beforeEach {
                    subject.setCreationMethod(AnObject.self) {
                        return AnObject(object: NSObject())
                    }
                }
                it("should set a custom creation method") {
                    expect((subject.create(AnObject.self) as AnObject).someObject).toNot(beNil())
                    expect((subject.create(AnObject.self) as AnObject).someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.setCreationMethod(AnObject.self) {
                        return AnObject(otherObject: NSObject())
                    }
                    expect((subject.create(AnObject.self) as AnObject).someObject).to(beNil())
                    expect((subject.create(AnObject.self) as AnObject).someOtherObject).toNot(beNil())
                }
                
                it("should allow the user to delete any existing creation method") {
                    subject.removeCreationMethod(AnObject.self)
                    expect((subject.create(AnObject.self) as AnObject).someObject).to(beNil())
                    expect((subject.create(AnObject.self) as AnObject).someOtherObject).to(beNil())
                }
            }
            
            context("when given a string") {
                beforeEach {
                    subject.setCreationMethod("Indeed") {
                        return AnObject(object: NSObject())
                    }
                }
                
                it("should set a custom creation method") {
                    expect((subject.create("Indeed") as AnObject).someObject).toNot(beNil())
                    expect((subject.create("Indeed") as AnObject).someOtherObject).to(beNil())
                }
                
                it("should write over any existing creation method") {
                    subject.setCreationMethod("Indeed") {
                        return AnObject(otherObject: NSObject())
                    }
                    expect((subject.create("Indeed") as AnObject).someObject).to(beNil())
                    expect((subject.create("Indeed") as AnObject).someOtherObject).toNot(beNil())
                }
                
                it("should allow the user to delete any existing creation method") {
                    subject.removeCreationMethod("Indeed")
                    expect(subject.create("Indeed")).to(beNil())
                }
            }
        }
    }
}