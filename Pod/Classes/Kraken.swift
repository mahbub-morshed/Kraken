//
//  Kraken
//
//  Copyright (c) 2016 Syed Sabir Salman-Al-Musawi <sabirvirtuoso@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation


/// MARK:- Base of all injectable types


public protocol Injectable: AnyObject {

  init()

}


/// MARK:- Custom Dependency Container (Dependency registration and injection implementation)


public final class Kraken {
  
  static var definitionMap = [String: DependencyDefinition]()
  static var singletons = [String: Injectable]()
  static var resolvedInstances = [String: Injectable]()
  
  init() {

  }
  
  public static func register(interface: Any, implementationType: Injectable.Type, scope: DependencyScope = .Prototype, completionHandler: ((resolvedInstance: Injectable) -> ())? = nil) {
    let definitionKey = String(interface)
    definitionMap[definitionKey] = ImplementationDefinition(scope: scope, implementationType: implementationType, completionHandler: completionHandler)
    
    switch scope {
        case .EagerSingleton: singletons[definitionKey] = implementationType.init()
        case .Singleton: break
        case .Prototype: break
    }
  }
  
  public static func register(interface: Any, implementation: Injectable) {
    let definitionKey = String(interface)
    definitionMap[definitionKey] = ImplementationDefinition(scope: .EagerSingleton, implementation: implementation)

    singletons[definitionKey] = implementation
  }

  public static func inject(typeToInject: Any) throws -> Injectable? {
    return try resolve(typeToInject)
  }

  private static var depth: Int = 0

  public static func resolve(typeToInject: Any) throws -> Injectable? {
    depth = depth + 1

    defer {
      depth = depth - 1

        if depth == 0 {
            resolvedInstances.removeAll()
        }
    }

    let definitionKey = String(typeToInject)

    guard definitionExists(forKey: definitionKey) else {
       throw KrakenError.DefinitionNotFound(key: definitionKey)
    }

    if let definition = resolvedInstances[definitionKey] {
      return definition
    }

    let dependencyDefinition: DependencyDefinition! = definitionMap[definitionKey]
    let resolvedInstance: Injectable?

    if let implementationDefinition = dependencyDefinition as? ImplementationDefinition {
      resolvedInstance = resolveImplementation(definitionKey, implementationDefinition: implementationDefinition)
      resolvedInstances[definitionKey] = resolvedInstance

      defer {
          invokeCompletionHandler(dependencyDefinition, resolvedInstance: resolvedInstance)
      }

      return resolvedInstance
    }

    if dependencyDefinition.numberOfArguments == 0 {
      resolvedInstance = try resolveFactory(typeToInject) { (factory: () -> Injectable?) in factory() }
      resolvedInstances[definitionKey] = resolvedInstance

      defer {
          invokeCompletionHandler(dependencyDefinition, resolvedInstance: resolvedInstance)
      }

      return resolvedInstance
    }

    return try resolveByAutoWiring(typeToInject)
  }

  private static func invokeCompletionHandler(dependencyDefinition: DependencyDefinition, resolvedInstance: Injectable?) {
    if dependencyDefinition.completionHandler != nil && resolvedInstance != nil {
      dependencyDefinition.completionHandler!(resolvedInstance!)
    }
  }

  private static func resolveImplementation(definitionKey: String, implementationDefinition: ImplementationDefinition) -> Injectable? {
    switch implementationDefinition.scope {
        case .EagerSingleton : return singletons[definitionKey]
        case .Singleton : return singletonInstance(definitionKey, implementationDefinition: implementationDefinition)
        case .Prototype : return implementationDefinition.implementationType!.init()
    }
  }

  static func definitionExists(forKey definitionKey: String) -> Bool {
    if let _ = definitionMap[definitionKey] {
        return true
    }

    return false
  }

  private static func singletonInstance(definitionKey: String, implementationDefinition: ImplementationDefinition) -> Injectable? {
    synchronized(Kraken.self) {
      if singletons[definitionKey] == nil {
        singletons[definitionKey] = implementationDefinition.implementationType!.init()
      }
    }

    return singletons[definitionKey]
  }

}


/// MARK:- Custom Dependency Container (Dependency removal implementation)


extension Kraken {
  
  public static func remove(interface: Any) {
    let definitionKey = String(interface)
    remove(definitionKey: definitionKey)
  }
  
  public static func remove(definitionKey key: String) {
    synchronized(Kraken.self) {
      definitionMap[key] = nil
      
      if let _ = singletons[key] {
        singletons[key] = nil
      }
    }
  }
  
  public static func reset() {
    synchronized(Kraken.self) {
      definitionMap.removeAll()
      singletons.removeAll()
    }
  }

}


/// MARK:- Circular Dependency handling


extension Kraken {

  public static func injectWeak(typeToInject: Any) throws -> WeakDependency {
    let resolvedInstance = try Kraken.inject(typeToInject)

    return WeakDependency(instance: resolvedInstance!)
  }

}

public final class WeakDependency {
  
  private weak var _value: Injectable!
  
  public var value: Injectable {
    return _value
  }
  
  init(instance: Injectable) {
    _value = instance
  }

}


/// MARK:- Global functions for injecting generic types without runtime arguments


public func inject<T where T: Any>(typeToInject: T.Type) -> T {
  return try! Kraken.inject(typeToInject) as! T
}

public func injectWeak(typeToInject: Any) -> WeakDependency {
  return try! Kraken.injectWeak(typeToInject)
}
