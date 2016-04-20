//
//  DependencyDefinition.swift
//  Pods
//
//  Created by Syed Sabir Salman on 3/30/16.
//
//

public final class ImplementationDefinition: DependencyDefinition {
  
  var scope: DependencyScope
  var implementationType: Injectable.Type?
  var implementation: Injectable?
  
  init(scope: DependencyScope, implementationType: Injectable.Type? = nil, implementation: Injectable? = nil) {
    self.scope = scope
    self.implementationType = implementationType
    self.implementation = implementation
  }
}

public final class FactoryDefinition<F>: DependencyDefinition {

  var scope: DependencyScope
  var factory: F
  var numberOfArguments: Int
  var argumentTypes: [Any]?

  init(scope: DependencyScope, factory: F, numberOfArguments: Int = 0, argumentTypes: [Any]? = nil) {
    self.scope = scope
    self.factory = factory
    self.numberOfArguments = numberOfArguments
    self.argumentTypes = argumentTypes
  }

  public func supportsAutowiring() -> Bool {
    let filteredArgumentTypesForAutowiring = argumentTypes?.filter({ $0 is Injectable })

    return numberOfArguments > 0 && filteredArgumentTypesForAutowiring?.count > 0
  }
}

public protocol DependencyDefinition: class {}