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

  public static func register<Arg1>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1) -> Injectable?) throws {
    if definitionExists(forKey: String(Arg1.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 1) { () throws -> Injectable? in
            try factory(Kraken.inject(Arg1) as! Arg1)
        }

        return
    }

    try verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 1)
  }

  public static func register<Arg1, Arg2>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1, Arg2) -> Injectable?) throws {
    if definitionExists(forKey: String(Arg1.self)) && definitionExists(forKey: String(Arg2.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 2) { () throws -> Injectable? in
            try factory(Kraken.inject(Arg1) as! Arg1, Kraken.inject(Arg2) as! Arg2)
        }

        return
    }

    try verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 2)
  }

  public static func register<Arg1, Arg2, Arg3>(interface: Any, scope: DependencyScope = .Prototype, factory: (Arg1, Arg2, Arg3) -> Injectable?) throws {
    if definitionExists(forKey: String(Arg1.self)) && definitionExists(forKey: String(Arg2.self)) && definitionExists(forKey: String(Arg3.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 3) { () throws -> Injectable? in
            try factory(Kraken.inject(Arg1) as! Arg1, Kraken.inject(Arg2) as! Arg2, Kraken.inject(Arg3) as! Arg3)
        }

        return
    }

    try verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 3)
  }

  private static func verifyScope(interface: Any, scope: DependencyScope) throws {
    let definitionKey = String(interface)

    switch scope {
        case .EagerSingleton: throw KrakenError.EagerSingletonNotAllowed(key: definitionKey)
        case .Singleton: break
        case .Prototype: break
    }
  }

  private static func registerFactory<F>(interface: Any, scope: DependencyScope, factory: F, numberOfArguments: Int = 0, completionHandler: ((Injectable) -> ())? = nil) {
    let definitionKey = String(interface)

    definitionMap[definitionKey] = FactoryDefinition(scope: scope, factory: factory, numberOfArguments: numberOfArguments, completionHandler: completionHandler)
  }

  private static func registerAutoWiringFactory(interface: Any, scope: DependencyScope, numberOfArguments: Int = 0, autoWiringFactory: () throws -> Injectable?) {
    let definitionKey = String(interface)

    let dependencydefinition = DependencyDefinition(scope: scope, numberOfArguments: 3)
    dependencydefinition.autoWiringFactory = autoWiringFactory

    definitionMap[definitionKey] = dependencydefinition
  }

}


/// MARK:- Custom Dependency Container (Dependency injection implementation with runtime arguments)


extension Kraken {

  public static func inject<Arg1>(typeToInject: Any, withArguments arg1: Arg1) throws -> Injectable? {
    return try resolveFactory(typeToInject, withNumberOfRuntimeArguments: 1) { (factory: (Arg1) -> Injectable?) in factory(arg1) }
  }

  public static func inject<Arg1, Arg2>(typeToInject: Any, withArguments arg1: Arg1, _ arg2: Arg2) throws -> Injectable? {
    return try resolveFactory(typeToInject, withNumberOfRuntimeArguments: 2) { (factory: (Arg1, Arg2) -> Injectable?) in factory(arg1, arg2) }
  }

  public static func inject<Arg1, Arg2, Arg3>(typeToInject: Any, withArguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) throws -> Injectable? {
    return try resolveFactory(typeToInject, withNumberOfRuntimeArguments: 3) { (factory: (Arg1, Arg2, Arg3) -> Injectable?) in factory(arg1, arg2, arg3) }
  }

  public static func resolveFactory<F>(typeToInject: Any, withNumberOfRuntimeArguments: Int = 0, builder: F -> Injectable?) throws -> Injectable? {
    let definitionKey = String(typeToInject)
    let factoryDefinition = try verifyAndReturnFactoryDefinition(typeToInject, withNumberOfRuntimeArguments: withNumberOfRuntimeArguments, builder: builder)

    switch factoryDefinition.scope {
        case .Singleton : return singletonInstance(definitionKey, factoryDefinition: factoryDefinition, builder: builder)
        case .Prototype : return builder(factoryDefinition.factory)
        default : return nil
    }
  }

  private static func verifyAndReturnFactoryDefinition<F>(typeToInject: Any, withNumberOfRuntimeArguments argumentCount: Int, builder: F -> Injectable?) throws -> FactoryDefinition<F> {
    let definitionKey = String(typeToInject)

    guard definitionExists(forKey: definitionKey) else {
      throw KrakenError.DefinitionNotFound(key: definitionKey)
    }

    let dependencyDefinition = definitionMap[definitionKey]

    guard let factoryDefinition = dependencyDefinition as? FactoryDefinition<F> else {
      throw KrakenError.FactoryNotFound(key: definitionKey)
    }

    guard factoryDefinition.numberOfArguments == argumentCount else {
      throw KrakenError.ArgumentCountNotMatched(key: definitionKey)
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


/// MARK:- Global functions for injecting generic types with 1, 2 and 3 runtime arguments respectively


public func inject<Arg1, T where T: Any>(typeToInject: T.Type, withArguments arg1: Arg1) -> T {
  return try! Kraken.inject(typeToInject, withArguments: arg1) as! T
}

public func inject<Arg1, Arg2, T where T: Any>(typeToInject: T.Type, withArguments arg1: Arg1, _ arg2: Arg2) -> T {
  return try! Kraken.inject(typeToInject, withArguments: arg1, arg2) as! T
}

public func inject<Arg1, Arg2, Arg3, T where T: Any>(typeToInject: T.Type, withArguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> T {
  return try! Kraken.inject(typeToInject, withArguments: arg1, arg2, arg3) as! T
}
