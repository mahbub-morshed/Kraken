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

  init(scope: DependencyScope, implementationType: Injectable.Type? = nil, implementation: Injectable? = nil, completionHandler: ((Injectable) -> ())? = nil) {
    self.implementationType = implementationType
    self.implementation = implementation
    super.init(scope: scope, completionHandler: completionHandler)
  }
}

public final class FactoryDefinition<F>: DependencyDefinition {

  var factory: F

  init(scope: DependencyScope, factory: F, numberOfArguments: Int = 0, completionHandler: ((Injectable) -> ())? = nil) {
    self.factory = factory
    super.init(scope: scope, numberOfArguments: numberOfArguments, completionHandler: completionHandler)
  }
}

public class DependencyDefinition {

  var scope: DependencyScope
  var numberOfArguments: Int
  var completionHandler: ((Injectable) -> ())?
  var autoWiringFactory: (() -> Injectable?)?

  init(scope: DependencyScope, numberOfArguments: Int = 0, completionHandler: ((Injectable) -> ())? = nil) {
    self.scope = scope
    self.numberOfArguments = numberOfArguments
    self.completionHandler = completionHandler
  }
}