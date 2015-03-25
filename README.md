Ra: Dependency Injection in swift

From [wikipedia](http://en.wikipedia.org/wiki/Ra): 

>All forms of life were believed to have been created by Ra, who called each of them into existence by speaking their secret names. Alternatively humans were created from Ra's tears and sweat, hence the Egyptians call themselves the "Cattle of Ra."

[![Build Status](https://api.travis-ci.org/younata/Ra.svg)](https://travis-ci.org/younata/Ra)

### Swift 1.2 Changes

- You can now create and register objects that don't inherit from NSObject. There are a few caveats, though:
  - You must bind to a string (classes for non-objc objects don't have a description method)
  - You must pre-register the binding (there won't be a default initializer to pick otherwise
- Because of the above change, `-create:` now returns type `AnyObject?`, in the event that the object isn't already registered and isn't a subclass of NSObject
