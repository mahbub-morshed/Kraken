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

  public static func register(_ interface: Any, implementationType: Injectable.Type, tag: DependencyTagConvertible? = nil, scope: DependencyScope = .prototype, completionHandler: ((_ resolvedInstance: Injectable) -> ())? = nil) {

    let definitionKey = prepareDefinitionKey(forInterface: interface, andTag: tag)
    definitionMap[definitionKey] = ImplementationDefinition(scope: scope, implementationType: implementationType, completionHandler: completionHandler)
    
    switch scope {
        case .eagerSingleton: singletons[definitionKey] = implementationType.init()
        case .singleton: break
        case .prototype: break
    }
  }

  public static func register(_ interface: Any, tag: DependencyTagConvertible? = nil, implementation: Injectable) {
    let definitionKey = prepareDefinitionKey(forInterface: interface, andTag: tag)
    definitionMap[definitionKey] = ImplementationDefinition(scope: .eagerSingleton, implementation: implementation)

    singletons[definitionKey] = implementation
  }

  public static func inject(_ typeToInject: Any, tag: DependencyTagConvertible? = nil) throws -> Injectable? {
    return try resolve(typeToInject, tag: tag)
  }

  fileprivate static var depth: Int = 0

  public static func resolve(_ typeToInject: Any, tag: DependencyTagConvertible? = nil) throws -> Injectable? {
    depth = depth + 1

    defer {
      depth = depth - 1

        if depth == 0 {
            resolvedInstances.removeAll()
        }
    }

    let definitionKey = prepareDefinitionKey(forInterface: typeToInject, andTag: tag)

    guard definitionExists(forKey: definitionKey) else {
       throw KrakenError.definitionNotFound(key: definitionKey)
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
        resolvedInstance = try resolveFactory(typeToInject, tag: tag) { (factory: () -> Injectable?) in factory() }
      resolvedInstances[definitionKey] = resolvedInstance

      defer {
          invokeCompletionHandler(dependencyDefinition, resolvedInstance: resolvedInstance)
      }

      return resolvedInstance
    }

    return try resolveByAutoWiring(typeToInject, tag: tag)
  }

  fileprivate static func invokeCompletionHandler(_ dependencyDefinition: DependencyDefinition, resolvedInstance: Injectable?) {
    if dependencyDefinition.completionHandler != nil && resolvedInstance != nil {
      dependencyDefinition.completionHandler!(resolvedInstance!)
    }
  }

  fileprivate static func resolveImplementation(_ definitionKey: String, implementationDefinition: ImplementationDefinition) -> Injectable? {
    switch implementationDefinition.scope {
        case .eagerSingleton: return singletons[definitionKey]
        case .singleton: return singletonInstance(definitionKey, implementationDefinition: implementationDefinition)
        case .prototype: return implementationDefinition.implementationType!.init()
    }
  }

  static func prepareDefinitionKey(forInterface interface: Any, andTag tag: DependencyTagConvertible?) -> String {
    guard let dependencyTag = tag else {
        return String(describing: interface)
    }

    return String(describing: interface) + String(describing: dependencyTag.dependencyTag)
  }

  static func definitionExists(forKey definitionKey: String) -> Bool {
    if let _ = definitionMap[definitionKey] {
        return true
    }

    return false
  }

  fileprivate static func singletonInstance(_ definitionKey: String, implementationDefinition: ImplementationDefinition) -> Injectable? {
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

  public static func remove(_ interface: Any, tag: DependencyTagConvertible? = nil) {
    let definitionKey = prepareDefinitionKey(forInterface: interface, andTag: tag)
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

  public static func injectWeak(_ typeToInject: Any, tag: DependencyTagConvertible? = nil) throws -> WeakDependency {
    let resolvedInstance = try Kraken.inject(typeToInject, tag: tag)

    return WeakDependency(instance: resolvedInstance!)
  }

}

public final class WeakDependency {

  fileprivate weak var _value: Injectable!

  public var value: Injectable {
    return _value
  }

  init(instance: Injectable) {
    _value = instance
  }

}


/// MARK:- Global functions for injecting generic types without runtime arguments


public func inject<T>(_ typeToInject: T.Type, tag: DependencyTagConvertible? = nil) -> T where T: Any {
  return try! Kraken.inject(typeToInject, tag: tag) as! T
}

public func injectWeak(_ typeToInject: Any, tag: DependencyTagConvertible? = nil) -> WeakDependency {
  return try! Kraken.injectWeak(typeToInject, tag: tag)
}
