//
//  AutoWiring.swift
//  Pods
//
//  Created by Syed Sabir Salman on 4/26/16.
//
//

import Foundation

extension Trigger {

  public static func resolveByAutoWiring(typeToInject: Any) -> Injectable? {
    let definitionKey = String(typeToInject)

    let dependencyDefinition: DependencyDefinition! = definitionMap[definitionKey]

    guard isAutoWiringSupported(forDefinition: dependencyDefinition) else {
      return nil
    }

    let filteredArguments = filteredArgumentTypesForAutoWiring(dependencyDefinition)
    return resolvedInstance(forType: typeToInject, withArgumentTypes: filteredArguments!)
  }

  private static func isAutoWiringSupported(forDefinition definition: DependencyDefinition) -> Bool {
    return definition.numberOfArguments > 0 && filteredArgumentTypesForAutoWiring(definition)?.count > 0
  }

  private static func filteredArgumentTypesForAutoWiring(definition: DependencyDefinition) -> [Any]? {
    return definition.argumentTypes?.filter({ $0 is Injectable })
  }

  private static func resolvedInstance(forType typeToInject: Any, withArgumentTypes arguments: [Any]) -> Injectable? {
    switch arguments.count {
        case 1: return Trigger.inject(typeToInject, withArguments: Trigger.resolve(arguments[0].self)!)
        case 2: return Trigger.inject(typeToInject, withArguments: Trigger.resolve(arguments[0].self)!,
                                      Trigger.resolve(arguments[1].self)!)
        case 3: return Trigger.inject(typeToInject, withArguments: Trigger.resolve(arguments[0].self)!,
                                      Trigger.resolve(arguments[1].self)!, Trigger.resolve(arguments[2].self)!)
        default:
            return nil
    }
  }
}
