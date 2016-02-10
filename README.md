Ra: Dependency Injection in swift

From [wikipedia](http://en.wikipedia.org/wiki/Ra): 

>All forms of life were believed to have been created by Ra, who called each of them into existence by speaking their secret names. Alternatively humans were created from Ra's tears and sweat, hence the Egyptians call themselves the "Cattle of Ra."

[![Build Status](https://api.travis-ci.org/younata/Ra.svg)](https://travis-ci.org/younata/Ra)

###Usage

```swift
import Ra

let injector = Ra.Injector()

injector.create(NSObject) // returns an NSObject, no need to cast

injector.bind("test", to: "result")
injector.create("test") // returns "result", must cast.

injector.bind("test") { injector in
  return ["hello": "world"]
}

injector.create("test") // returns ["Hello": "world"], is evaluated/created when this is called.
// note that this just overwrote the previous binding.

injector.removeBinding("test")
injector.create("test") // returns nil

```

###Installing

####Carthage

For Swift 2.0/2.1

* add `github "younata/Ra"`

For Swift 1.2

* add `github "younata/Ra" ~= 0.3`

For Swift 1.1

* add `github "younata/Ra" == 0.1.0`

####Cocoapods

Make sure that `use_frameworks!` is defined in your Podfile

For Swift 2.0/2.1

* add `pod "Ra" :git => "https://github.com/younata/Ra.git"`

For Swift 1.2

* add `pod "Ra" :git => "https://github.com/younata/Ra.git", :tag => "v0.3.2"`

For Swift 1.1

* add `pod "Ra" :git => "https://github.com/younata/Ra.git", :tag => "0.1.0"`


#####Swift Package Manager

add `.Package(url: "https://github.com/younata/Ra", majorVersion: 1)` to the dependencies array in your `Package.swift` file.


=======
### ChangeLog

#### 1.0.0

- Add support for the Swift Package Manager
- Removed extension adding the injector instance to every NSObject created.
- Binding with a block now takes an injector instance as the argument
- Adds a smoke test for a somewhat-complicated dependency graph

#### 0.5.0

- Add type checking/generics for anything that asks for something of a given type/protocol. Using a string as the key still doesn't do type checking. This means that you don't have to type check what you get back.
- Change the binding API to not use autoclosures, and instead allow you to directly bind instances. This effectively treats that instance as a singleton (the singleton behavior only works for types that are classes, not structs), for example:

```swift
injector.bind(NSObject, toInstance: NSObject())

injector.create(NSObject) === injector.create(NSObject) // true

struct MyStruct {
    var myValue = 10

    init() {}
}

var myStruct = MyStruct()

myStruct.myValue = 100

injector.bind(MyStruct, toInstance: myStruct)
injector.create(MyStruct)?.myValue // 10
```
- `Type.self` is no longer necessary when using type names.
- tvOS support

#### 0.4.0

- Add the Injectable protocol, that can be optionally conformed to so that you can configure your object at Init time with stuff from an Injector.
- Swift 2.0 support.
- Sets the proper flag to make this usable in extensions.
- Allows anything to be a key (protocols drove out this change).
- WatchOS support

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

