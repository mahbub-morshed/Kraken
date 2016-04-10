//
//  DependencyDefinition.swift
//  Pods
//
//  Created by Syed Sabir Salman on 3/30/16.
//
//

public final class DependencyDefinition {
  
  var scope: DependencyScope
  var implementationType: Injectable.Type?
  var implementation: Injectable?
  
  init(scope: DependencyScope, implementationType: Injectable.Type? = nil, implementation: Injectable? = nil) {
    self.scope = scope
    self.implementationType = implementationType
    self.implementation = implementation
  }
}