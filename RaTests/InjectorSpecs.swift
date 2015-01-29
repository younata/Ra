import Quick
import Nimble
import Ra

class InjectorSpec: QuickSpec {
    override func spec() {
        var subject : Injector! = nil

        beforeEach {
            subject = Ra.Injector()
        }

        describe("Creating objects through classes") {
            describe("Creating objects using standard initializer") {
                it("Should create an object using the standard init()") {
                    expect(subject.create(NSObject.self)).to(beAnInstanceOf(NSObject.self))
                }
            }

            describe("Creating objects using a custom initializer") {
                class SomeObject : NSObject {
                    override init() {
                        fatalError("Should not happen")
                    }

                    init(object: ()) {
                        super.init()
                    }
                }

                it("should use the custom initializer") {
                    subject.creationMethods[SomeObject.description()] = {
                        return SomeObject(object: ())
                    }
                    expect(subject.create(SomeObject.self)).to(beAnInstanceOf(SomeObject.self))
                }
            }
        }

        describe("Creating objects through strings") {
            it("should return nil if there is not an existing creation method for a string") {
                expect(subject.create("Sholvah!")).to(beNil())
            }

            it("should return an instance of a class if there is an existing creation method for the string") {
                subject.creationMethods["I die free"] = {
                    return NSDictionary()
                }

                expect(subject.create("I die free")).to(beAKindOf(NSDictionary.self))
            }
        }
    }
}