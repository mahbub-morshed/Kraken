//
//  Trigger.swift
//  Pods
//
//  Created by Syed Sabir Salman on 3/30/16.
//
//


/// MARK:- Base of all injectable types


public protocol Injectable: AnyObject {
  init()
}


/// MARK:- Custom Dependency Container (Dependency registration and injection implementation)


public final class Trigger {
  
  private static var definitionMap = [String: DependencyDefinition]()
  private static var singletons = [String: Injectable]()
  
  init() {
  }
  
  public static func register(interface: Any.Type, implementationType: Injectable.Type, scope: DependencyScope = .Prototype) {
    let definitionKey = String(interface)
    definitionMap[definitionKey] = DependencyDefinition(scope: scope, implementationType: implementationType)
    
    switch scope {
        case .EagerSingleton: singletons[definitionKey] = implementationType.init()
        case .Singleton: break
        case .Prototype: break
    }
  }
  
  public static func register(interface: Any.Type, implementation: Injectable) {
    let definitionKey = String(interface)
    definitionMap[definitionKey] = DependencyDefinition(scope: .EagerSingleton, implementation: implementation)

    singletons[definitionKey] = implementation
  }

  public static func inject<T where T: Any>(typeToInject: T.Type) -> Injectable? {
    return resolve(typeToInject)
  }
  
  private static func resolve(typeToInject: Any.Type) -> Injectable? {
    let definitionKey = String(typeToInject)
    
    guard let dependencyDefinition = definitionMap[definitionKey] else {
      fatalError("No object registered for type: \(definitionKey). Did you forget to call register:implementation:scope: for type \(definitionKey)")
    }
    
    switch dependencyDefinition.scope {
        case .EagerSingleton : return singletons[definitionKey]
        case .Singleton : return singletonInstance(definitionKey, dependencyDefinition: dependencyDefinition)
        case .Prototype : return dependencyDefinition.implementationType!.init()
    }
  }
  
  private static func singletonInstance(definitionKey: String, dependencyDefinition: DependencyDefinition) -> Injectable? {
    synchronized(Trigger.self) {
      if singletons[definitionKey] == nil {
        singletons[definitionKey] = dependencyDefinition.implementationType!.init()
      }
    }
    
    return singletons[definitionKey]
  }
}


/// MARK:- Custom Dependency Container (Dependency removal implementation)


extension Trigger {
  
  public static func remove(interface: Any.Type) {
    let definitionKey = String(interface)
    remove(definitionKey: definitionKey)
  }
  
  public static func remove(definitionKey key: String) {
    synchronized(Trigger.self) {
      definitionMap[key] = nil
      
      if let _ = singletons[key] {
        singletons[key] = nil
      }
    }
  }
  
  public static func reset() {
    synchronized(Trigger.self) {
      definitionMap.removeAll()
      singletons.removeAll()
    }
  }
}


/// MARK:- Circular Dependency handling


extension Trigger {
  
  static func injectWeak<T where T: Any>(typeToInject: T.Type) -> WeakDependency {
    return WeakDependency(instance: resolve(typeToInject)!)
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
