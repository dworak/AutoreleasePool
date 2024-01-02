# Autorelease Pool

A simple Swift implementation of an autorelease pool. Autorelease pools help manage memory in situations where objects need to be released at a later point in time. The implementation follows the basic principles of autorelease pools in Objective-C.

## Usage

```swift
DispatchQueue.concurrentPerform(iterations: 10) { _ in
  var pool: AutoreleasePool? = AutoreleasePool()
  var object: AnyObject? = TestObject().autorelease()
  pool?.drain()
  pool = nil
}
