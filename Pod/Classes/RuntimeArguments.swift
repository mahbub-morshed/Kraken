//
//  RuntimeArguments.swift
//  Pods
//
//  Created by Syed Sabir Salman on 4/20/16.
//
//


/// MARK:- Custom Dependency Container (Dependency Factory registration with runtime arguments)


extension Trigger {

  public static func register(interface: Any, scope: DependencyScope = .Prototype, factory: () -> Injectable?, completionHandler: ((a: Injectable) -> ())? = nil) {
    let definitionKey = String(interface)
    registerFactory(interface, scope: scope, factory: factory, completionHandler: completionHandler)

    switch scope {
        case .EagerSingleton: singletons[definitionKey] = factory()!
        case .Singleton: break
        case .Prototype: break
    }
  }

  public static func register<Arg1>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1) -> Injectable?) {
    verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 1, argumentTypes: [Arg1.self])
  }

  public static func register<Arg1, Arg2>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1, Arg2) -> Injectable?) {
    verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 2, argumentTypes: [Arg1.self, Arg2.self])
  }

  public static func register<Arg1, Arg2, Arg3>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1, Arg2, Arg3) -> Injectable?) {
    verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 3, argumentTypes: [Arg1.self, Arg2.self, Arg3.self])
  }

  private static func verifyScope(interface: Any, scope: DependencyScope) {
    let definitionKey = String(interface)

    switch scope {
        case .EagerSingleton: fatalError("Cannot register factory with runtime arguments for type: \(definitionKey). Scope cannot be EagerSingleton.")
        case .Singleton: break
        case .Prototype: break
    }
  }

  private static func registerFactory<F>(interface: Any, scope: DependencyScope, factory: F, numberOfArguments: Int = 0, argumentTypes: [Any]? = nil, completionHandler: ((Injectable) -> ())? = nil) {
    let definitionKey = String(interface)

    definitionMap[definitionKey] = FactoryDefinition(scope: scope, factory: factory, numberOfArguments: numberOfArguments, argumentTypes: argumentTypes, completionHandler: completionHandler)
  }
}


/// MARK:- Custom Dependency Container (Dependency injection implementation with runtime arguments)


extension Trigger {

  public static func inject<Arg1>(typeToInject: Any, withArguments arg1: Arg1) -> Injectable? {
    return resolveFactory(typeToInject, withNumberOfRuntimeArguments: 1) { (factory: (Arg1) -> Injectable?) in factory(arg1) }
  }

  public static func inject<Arg1, Arg2>(typeToInject: Any, withArguments arg1: Arg1, _ arg2: Arg2) -> Injectable? {
    return resolveFactory(typeToInject, withNumberOfRuntimeArguments: 2) { (factory: (Arg1, Arg2) -> Injectable?) in factory(arg1, arg2) }
  }

  public static func inject<Arg1, Arg2, Arg3>(typeToInject: Any, withArguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> Injectable? {
    return resolveFactory(typeToInject, withNumberOfRuntimeArguments: 3) { (factory: (Arg1, Arg2, Arg3) -> Injectable?) in factory(arg1, arg2, arg3) }
  }

  public static func resolveFactory<F>(typeToInject: Any, withNumberOfRuntimeArguments: Int = 0, builder: F -> Injectable?) -> Injectable? {
    let definitionKey = String(typeToInject)
    let factoryDefinition = verifyAndReturnFactoryDefinition(typeToInject, withNumberOfRuntimeArguments: withNumberOfRuntimeArguments, builder: builder)

    switch factoryDefinition.scope {
        case .Singleton : return singletonInstance(definitionKey, factoryDefinition: factoryDefinition, builder: builder)
        case .Prototype : return builder(factoryDefinition.factory)
        default : return nil
    }
  }

  private static func verifyAndReturnFactoryDefinition<F>(typeToInject: Any, withNumberOfRuntimeArguments argumentCount: Int, builder: F -> Injectable?) -> FactoryDefinition<F> {
    let definitionKey = String(typeToInject)
    definitionExists(forKey: definitionKey)

    let dependencyDefinition = definitionMap[definitionKey]

    guard let factoryDefinition = dependencyDefinition as? FactoryDefinition<F> else {
      fatalError("No factory definition is registered for type: \(definitionKey)")
    }

    guard factoryDefinition.numberOfArguments == argumentCount else {
      fatalError("Number of arguments expected by factory of type: \(definitionKey) does not match with actual arguments passed")
    }

    return factoryDefinition
  }

  private static func singletonInstance<F>(definitionKey: String, factoryDefinition: FactoryDefinition<F>, builder: F -> Injectable?) -> Injectable? {
    synchronized(Trigger.self) {
      if singletons[definitionKey] == nil {
        singletons[definitionKey] = builder(factoryDefinition.factory)!
      }
    }

    return singletons[definitionKey]
  }
}
