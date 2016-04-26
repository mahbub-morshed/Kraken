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
  
  static var definitionMap = [String: DependencyDefinition]()
  static var singletons = [String: Injectable]()
  
  init() {
  }
  
  public static func register(interface: Any, implementationType: Injectable.Type, scope: DependencyScope = .Prototype) {
    let definitionKey = String(interface)
    definitionMap[definitionKey] = ImplementationDefinition(scope: scope, implementationType: implementationType)
    
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

  public static func inject(typeToInject: Any) -> Injectable? {
    return resolve(typeToInject)
  }

  public static func resolve(typeToInject: Any) -> Injectable? {
    let definitionKey = String(typeToInject)

    definitionExists(forKey: definitionKey)
    let dependencyDefinition: DependencyDefinition! = definitionMap[definitionKey]

    if let implementationDefinition = dependencyDefinition as? ImplementationDefinition {
      return resolveImplementation(definitionKey, implementationDefinition: implementationDefinition)
    }

    if dependencyDefinition.numberOfArguments == 0 {
      return resolveFactory(typeToInject) { (factory: () -> Injectable?) in factory() }
    }

    return resolveByAutoWiring(typeToInject)
  }

  private static func resolveImplementation(definitionKey: String, implementationDefinition: ImplementationDefinition) -> Injectable? {
    switch implementationDefinition.scope {
        case .EagerSingleton : return singletons[definitionKey]
        case .Singleton : return singletonInstance(definitionKey, implementationDefinition: implementationDefinition)
        case .Prototype : return implementationDefinition.implementationType!.init()
    }
  }

  static func definitionExists(forKey definitionKey: String) {
    guard let _ = definitionMap[definitionKey] else {
      fatalError("No object registered for type: \(definitionKey). Did you forget to call register:implementation:scope: for type \(definitionKey)")
    }
  }

  private static func singletonInstance(definitionKey: String, implementationDefinition: ImplementationDefinition) -> Injectable? {
    synchronized(Trigger.self) {
      if singletons[definitionKey] == nil {
        singletons[definitionKey] = implementationDefinition.implementationType!.init()
      }
    }

    return singletons[definitionKey]
  }
}


/// MARK:- Custom Dependency Container (Dependency removal implementation)


extension Trigger {
  
  public static func remove(interface: Any) {
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
