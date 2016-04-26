//
//  DependencyDefinition.swift
//  Pods
//
//  Created by Syed Sabir Salman on 3/30/16.
//
//

public final class ImplementationDefinition: DependencyDefinition {

  var implementationType: Injectable.Type?
  var implementation: Injectable?

  init(scope: DependencyScope, implementationType: Injectable.Type? = nil, implementation: Injectable? = nil) {
    self.implementationType = implementationType
    self.implementation = implementation
    super.init(scope: scope)
  }
}

public final class FactoryDefinition<F>: DependencyDefinition {

  var factory: F

  init(scope: DependencyScope, factory: F, numberOfArguments: Int = 0, argumentTypes: [Any]? = nil) {
    self.factory = factory
    super.init(scope: scope, numberOfArguments: numberOfArguments, argumentTypes: argumentTypes)
  }

  public func supportsAutowiring() -> Bool {
    let filteredArgumentTypesForAutowiring = argumentTypes?.filter({ $0 is Injectable })

    return numberOfArguments > 0 && filteredArgumentTypesForAutowiring?.count > 0
  }
}

public class DependencyDefinition {

  var scope: DependencyScope
  var numberOfArguments: Int
  var argumentTypes: [Any]?

  init(scope: DependencyScope, numberOfArguments: Int = 0, argumentTypes: [Any]? = nil) {
    self.scope = scope
    self.numberOfArguments = numberOfArguments
    self.argumentTypes = argumentTypes
  }
}