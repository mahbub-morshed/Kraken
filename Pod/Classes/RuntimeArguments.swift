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


/// MARK:- Custom Dependency Container (Dependency Factory registration with runtime arguments)


extension Kraken {

  public static func register(interface: Any, scope: DependencyScope = .Prototype, factory: () -> Injectable?, completionHandler: ((resolvedInstance: Injectable) -> ())? = nil) {
    let definitionKey = String(interface)
    registerFactory(interface, scope: scope, factory: factory, completionHandler: completionHandler)

    switch scope {
        case .EagerSingleton: singletons[definitionKey] = factory()!
        case .Singleton: break
        case .Prototype: break
    }
  }

  public static func register<Arg1>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1) -> Injectable?) {
    if definitionExists(forKey: String(Arg1.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 1) { () -> Injectable? in
            factory(Kraken.inject(Arg1) as! Arg1)
        }

        return
    }

    verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 1)
  }

  public static func register<Arg1, Arg2>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1, Arg2) -> Injectable?) {
    if definitionExists(forKey: String(Arg1.self)) && definitionExists(forKey: String(Arg2.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 2) { () -> Injectable? in
            factory(Kraken.inject(Arg1) as! Arg1, Kraken.inject(Arg2) as! Arg2)
        }

        return
    }

    verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 2)
  }

  public static func register<Arg1, Arg2, Arg3>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1, Arg2, Arg3) -> Injectable?) {
    if definitionExists(forKey: String(Arg1.self)) && definitionExists(forKey: String(Arg2.self)) && definitionExists(forKey: String(Arg3.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 3) { () -> Injectable? in
            factory(Kraken.inject(Arg1) as! Arg1, Kraken.inject(Arg2) as! Arg2, Kraken.inject(Arg3) as! Arg3)
        }

        return
    }

    verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 3)
  }

  private static func verifyScope(interface: Any, scope: DependencyScope) {
    let definitionKey = String(interface)

    switch scope {
        case .EagerSingleton: fatalError("Cannot register factory with runtime arguments for type: \(definitionKey). Scope cannot be EagerSingleton.")
        case .Singleton: break
        case .Prototype: break
    }
  }

  private static func registerFactory<F>(interface: Any, scope: DependencyScope, factory: F, numberOfArguments: Int = 0, completionHandler: ((Injectable) -> ())? = nil) {
    let definitionKey = String(interface)

    definitionMap[definitionKey] = FactoryDefinition(scope: scope, factory: factory, numberOfArguments: numberOfArguments, completionHandler: completionHandler)
  }

  private static func registerAutoWiringFactory(interface: Any, scope: DependencyScope, numberOfArguments: Int = 0, autoWiringFactory: () -> Injectable?) {
    let definitionKey = String(interface)

    let dependencydefinition = DependencyDefinition(scope: scope, numberOfArguments: 3)
    dependencydefinition.autoWiringFactory = autoWiringFactory

    definitionMap[definitionKey] = dependencydefinition
  }
}


/// MARK:- Custom Dependency Container (Dependency injection implementation with runtime arguments)


extension Kraken {

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

    guard definitionExists(forKey: definitionKey) else {
        fatalError("No object registered for type: \(definitionKey). Did you forget to call register:implementation:scope: for type \(definitionKey)")
    }

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
    synchronized(Kraken.self) {
      if singletons[definitionKey] == nil {
        singletons[definitionKey] = builder(factoryDefinition.factory)!
      }
    }

    return singletons[definitionKey]
  }
}
