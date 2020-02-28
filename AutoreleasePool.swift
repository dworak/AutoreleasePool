import Foundation

final class AutoreleasePool: NSObject {
  private var objects: [AnyObject]
  private static let key = "AutoreleasePoolKey"
  
  override init() {
    print("init")
    objects = [AnyObject]()
    super.init()
    AutoreleasePool.threadPoolStack?.append(self)
  }
  
  deinit {
    print("deinit from \(Thread.current)")
    objects.removeAll()
    var stack = AutoreleasePool.threadPoolStack
    var index = stack?.count ?? 0
    while index > 0 {
      index -= 1
      let pool = stack?[index] as? AutoreleasePool
      if pool == self {
        print("removing self")
        stack?.remove(at: index)
        break
      }
    }
  }
  
  static var threadPoolStack: [AnyObject]? {
    get {
      let threadDictionary = Thread.current.threadDictionary
      var array = threadDictionary[key] as? [AnyObject]
      if array == nil {
        array = [AnyObject]()
        threadDictionary[key] = array
      }
      return array
    }
    set {
      Thread.current.threadDictionary[key] = newValue
    }
  }
  
  static func addObject(_ object: inout AnyObject) {
    let stack = threadPoolStack
    let count = stack?.count ?? 0
    if count == 0 {
      print("object leaking")
    } else {
      let pool = stack?[count - 1] as? AutoreleasePool
      pool?.add(&object)
    }
  }
  
  func add(_ object: inout AnyObject) {
    objects.append(object)
  }
  
  func drain() {
    AutoreleasePool.threadPoolStack = nil
  }
}

class TestObject: NSObject {
  deinit {
    print("Test object released")
  }
}

extension NSObject {
  func autorelease() -> AnyObject {
    var `self`: AnyObject = self
    AutoreleasePool.addObject(&self)
    return `self`
  }
}

DispatchQueue.concurrentPerform(iterations: 10) { _ in
  var pool: AutoreleasePool? = AutoreleasePool()
  var object: AnyObject? = TestObject().autorelease()
  pool?.drain()
  pool = nil
}

