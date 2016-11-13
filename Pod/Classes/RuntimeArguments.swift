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

  public static func register(_ interface: Any, scope: DependencyScope = .prototype, factory: () -> Injectable?, completionHandler: ((_ resolvedInstance: Injectable) -> ())? = nil) {
    let definitionKey = String(describing: interface)
    registerFactory(interface, scope: scope, factory: factory, completionHandler: completionHandler)

    switch scope {
        case .eagerSingleton: singletons[definitionKey] = factory()!
        case .singleton: break
        case .prototype: break
    }
  }

  public static func register<Arg1>(_ interface: Any, scope: DependencyScope = .prototype, factory: @escaping (Arg1) -> Injectable?) throws {
    if definitionExists(forKey: String(describing: Arg1.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 1) { () throws -> Injectable? in
            try factory(Kraken.inject(Arg1) as! Arg1)
        }

        return
    }

    try verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 1)
  }

  public static func register<Arg1, Arg2>(_ interface: Any, scope: DependencyScope = .prototype, factory: @escaping (Arg1, Arg2) -> Injectable?) throws {
    if definitionExists(forKey: String(describing: Arg1.self)) && definitionExists(forKey: String(describing: Arg2.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 2) { () throws -> Injectable? in
            try factory(Kraken.inject(Arg1) as! Arg1, Kraken.inject(Arg2) as! Arg2)
        }

        return
    }

    try verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 2)
  }

  public static func register<Arg1, Arg2, Arg3>(_ interface: Any, scope: DependencyScope = .prototype, factory: @escaping (Arg1, Arg2, Arg3) -> Injectable?) throws {
    if definitionExists(forKey: String(describing: Arg1.self)) && definitionExists(forKey: String(describing: Arg2.self)) && definitionExists(forKey: String(describing: Arg3.self)) {

        registerAutoWiringFactory(interface, scope: scope, numberOfArguments: 3) { () throws -> Injectable? in
            try factory(Kraken.inject(Arg1) as! Arg1, Kraken.inject(Arg2) as! Arg2, Kraken.inject(Arg3) as! Arg3)
        }

        return
    }

    try verifyScope(interface, scope: scope)
    registerFactory(interface, scope: scope, factory: factory, numberOfArguments: 3)
  }

  fileprivate static func verifyScope(_ interface: Any, scope: DependencyScope) throws {
    let definitionKey = String(describing: interface)

    switch scope {
        case .eagerSingleton: throw KrakenError.eagerSingletonNotAllowed(key: definitionKey)
        case .singleton: break
        case .prototype: break
    }
  }

  fileprivate static func registerFactory<F>(_ interface: Any, scope: DependencyScope, factory: F, numberOfArguments: Int = 0, completionHandler: ((Injectable) -> ())? = nil) {
    let definitionKey = String(describing: interface)

    definitionMap[definitionKey] = FactoryDefinition(scope: scope, factory: factory, numberOfArguments: numberOfArguments, completionHandler: completionHandler)
  }

  fileprivate static func registerAutoWiringFactory(_ interface: Any, scope: DependencyScope, numberOfArguments: Int = 0, autoWiringFactory: @escaping () throws -> Injectable?) {
    let definitionKey = String(describing: interface)

    let dependencydefinition = DependencyDefinition(scope: scope, numberOfArguments: 3)
    dependencydefinition.autoWiringFactory = autoWiringFactory

    definitionMap[definitionKey] = dependencydefinition
  }

}


/// MARK:- Custom Dependency Container (Dependency injection implementation with runtime arguments)


extension Kraken {

  public static func inject<Arg1>(_ typeToInject: Any, withArguments arg1: Arg1) throws -> Injectable? {
    return try resolveFactory(typeToInject) { (factory: (Arg1) -> Injectable?) in factory(arg1) }
  }

  public static func inject<Arg1, Arg2>(_ typeToInject: Any, withArguments arg1: Arg1, _ arg2: Arg2) throws -> Injectable? {
    return try resolveFactory(typeToInject) { (factory: (Arg1, Arg2) -> Injectable?) in factory(arg1, arg2) }
  }

  public static func inject<Arg1, Arg2, Arg3>(_ typeToInject: Any, withArguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) throws -> Injectable? {
    return try resolveFactory(typeToInject) { (factory: (Arg1, Arg2, Arg3) -> Injectable?) in factory(arg1, arg2, arg3) }
  }

  public static func resolveFactory<F>(_ typeToInject: Any, builder: @escaping (F) -> Injectable?) throws -> Injectable? {
    let definitionKey = String(describing: typeToInject)
    let factoryDefinition = try verifyAndReturnFactoryDefinition(typeToInject, builder: builder)

    switch factoryDefinition.scope {
        case .singleton : return singletonInstance(definitionKey, factoryDefinition: factoryDefinition, builder: builder)
        case .prototype : return builder(factoryDefinition.factory)
        default : return nil
    }
  }

  fileprivate static func verifyAndReturnFactoryDefinition<F>(_ typeToInject: Any, builder: (F) -> Injectable?) throws -> FactoryDefinition<F> {
    let definitionKey = String(describing: typeToInject)

    guard definitionExists(forKey: definitionKey) else {
      throw KrakenError.definitionNotFound(key: definitionKey)
    }

    let dependencyDefinition = definitionMap[definitionKey]

    guard let factoryDefinition = dependencyDefinition as? FactoryDefinition<F> else {
      if dependencyDefinition!.numberOfArguments == 0 {
        throw KrakenError.factoryNotFound(key: definitionKey)
      }

      throw KrakenError.argumentCountNotMatched(key: definitionKey)
    }

    return factoryDefinition
  }

  fileprivate static func singletonInstance<F>(_ definitionKey: String, factoryDefinition: FactoryDefinition<F>, builder: @escaping (F) -> Injectable?) -> Injectable? {
    synchronized(Kraken.self) {
      if singletons[definitionKey] == nil {
        singletons[definitionKey] = builder(factoryDefinition.factory)!
      }
    }

    return singletons[definitionKey]
  }

}


/// MARK:- Global functions for injecting generic types with 1, 2 and 3 runtime arguments respectively


public func inject<Arg1, T>(_ typeToInject: T.Type, withArguments arg1: Arg1) -> T where T: Any {
  return try! Kraken.inject(typeToInject, withArguments: arg1) as! T
}

public func inject<Arg1, Arg2, T>(_ typeToInject: T.Type, withArguments arg1: Arg1, _ arg2: Arg2) -> T where T: Any {
  return try! Kraken.inject(typeToInject, withArguments: arg1, arg2) as! T
}

public func inject<Arg1, Arg2, Arg3, T>(_ typeToInject: T.Type, withArguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3) -> T where T: Any {
  return try! Kraken.inject(typeToInject, withArguments: arg1, arg2, arg3) as! T
}
