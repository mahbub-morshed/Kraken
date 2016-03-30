//
//  DependencyDefinition.swift
//  Pods
//
//  Created by Syed Sabir Salman on 3/30/16.
//
//

public final class DependencyDefinition {
  
  var scope: DependencyScope
  var implementationType: Injectable.Type
  
  init(scope: DependencyScope, implementationType: Injectable.Type) {
    self.scope = scope
    self.implementationType = implementationType
  }
}