//
//  AutoWiring.swift
//  Pods
//
//  Created by Syed Sabir Salman on 4/26/16.
//
//

import Foundation

extension Kraken {

  public static func resolveByAutoWiring(typeToInject: Any) -> Injectable? {
    let definitionKey = String(typeToInject)

    let dependencyDefinition: DependencyDefinition! = definitionMap[definitionKey]

    guard isAutoWiringSupported(forDefinition: dependencyDefinition) else {
      return nil
    }

    return dependencyDefinition.autoWiringFactory!()
  }

  private static func isAutoWiringSupported(forDefinition definition: DependencyDefinition) -> Bool {
    return definition.numberOfArguments > 0 && definition.autoWiringFactory != nil
  }
}
