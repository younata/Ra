R a: Dependency Injection in swift

From [wikipedia](http://en.wikipedia.org/wiki/Ra): 

>All forms of life were believed to have been created by Ra, who called each of them into existence by speaking their secret names. Alternatively humans were created from Ra's tears and sweat, hence the Egyptians call themselves the "Cattle of Ra."

[![Build Status](https://api.travis-ci.org/younata/Ra.svg)](https://travis-ci.org/younata/Ra)

###Usage

```swift
import Ra

let injector = Ra.Injector()

injector.create(NSObject.self) // returns an NSObject

injector.bind("test", to: "result")
injector.create("test") // returns "result"

class MyClass : NSObject {
}

let myObject = injector.create(MyClass) as! MyClass
myObject.injector // returns injector

injector.bind("test") {
  return ["hello": "world"]
}

injector.create("test") // returns ["Hello": "world"], is evaluated/created when this is called.
// note that this just overwrote the previous binding.

injector.removeBinding("test")
injector.create("test") // returns nil

```

###Installing

####Carthage

For Swift 2.0

* add `github "younata/Ra" "swift_2"`

For Swift 1.2

* add `github "younata/Ra"`

For Swift 1.1

* add `github "younata/Ra" == 0.1.0`

####Cocoapods

Make sure that `use_frameworks!` is defined in your Podfile

For Swift 2.0

* add `pod "Ra" :git => "https://github.com/younata/Ra.git", :branch => "swift_2"`

For Swift 1.2

* add `pod "Ra" :git => "https://github.com/younata/Ra.git"`

For Swift 1.1

* add `pod "Ra" :git => "https://github.com/younata/Ra.git", :tag => "0.1.0"`

=======
### ChangeLog

#### 0.4.0

- Add the Injectable protocol, that can be optionally conformed to so that you can configure your object at Init time with stuff from an Injector.
- Swift 2.0 support

#### 0.3.1

- Add official support for injector modules. Use the new convenience initializer `init(modules: InjectorModule...)` to configure with any number of objects that confirm to InjectorModule. Note that if there are any conflicts in which injectormodule binds which, the last one to be passed in will succeed.

#### 0.3.0

- Simplified public interface, there's now only 1 create, 2 add binding and 1 remove binding public methods, which take Any types as there arguments, but really only do things when given an argument of type `AnyClass` or `String`. Otherwise they either silently fail, or return nil.
- Additionally, you can now bind any swift type as well.

#### 0.2.0

- You can now create and register objects that don't inherit from NSObject. There are a few caveats, though:
  - You must bind to a string (classes for non-objc objects don't have a description method)
  - You must pre-register the binding (there won't be a default initializer to pick otherwise
- Because of the above change, `-create:` now returns type `AnyObject?`, in the event that the object isn't already registered and isn't a subclass of NSObject

#### 0.1.0

- Swift 1.1 support
- Can only create/bind objects that inherit from NSObject

=======
### License

[MIT](LICENSE)

