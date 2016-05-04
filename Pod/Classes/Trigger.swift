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

  public static func inject(typeToInject: Any) -> Injectable? {
    return resolve(typeToInject)
  }

  private static var depth: Int = 0

  public static func resolve(typeToInject: Any) -> Injectable? {
    depth = depth + 1

    defer {
      depth = depth - 1

        if depth == 0 {
            resolvedInstances.removeAll()
        }
    }

    let definitionKey = String(typeToInject)
    definitionExists(forKey: definitionKey)

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
      resolvedInstance = resolveFactory(typeToInject) { (factory: () -> Injectable?) in factory() }
      resolvedInstances[definitionKey] = resolvedInstance

      defer {
          invokeCompletionHandler(dependencyDefinition, resolvedInstance: resolvedInstance)
      }

      return resolvedInstance
    }

    return resolveByAutoWiring(typeToInject)
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
  
  public static func injectWeak(typeToInject: Any) -> WeakDependency {
    return WeakDependency(instance: inject(typeToInject)!)
  }

  public static func injectWeak<Arg1>(typeToInject: Any, withRuntimeArguments arg1: Arg1) -> WeakDependency {
    return WeakDependency(instance: inject(typeToInject, withArguments: arg1)!)
  }

  public static func injectWeak<Arg1, Arg2>(typeToInject: Any, withArguments arg1: Arg1, _ arg2: Arg2) -> WeakDependency {
    return WeakDependency(instance: inject(typeToInject, withArguments: arg1, arg2)!)
  }

  public static func injectWeak<Arg1, Arg2, Arg3>(typeToInject: Any, withArguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> WeakDependency {
    return WeakDependency(instance: inject(typeToInject, withArguments: arg1, arg2, arg3)!)
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
