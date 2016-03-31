//
//  DependencyConfigurator.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/31/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Trigger

class DependencyConfigurator {
  
  static func bootstrapDependencies() {
    Trigger.register(ServiceA.self, implementation: ServiceAImpl.self, scope: .Prototype)
    Trigger.register(ServiceB.self, implementation: ServiceBImpl.self, scope: .Prototype)
    
    Trigger.register(ServiceC.self, implementation: ServiceCImpl.self)
    
    Trigger.register(GenericDataSource<ServiceAImpl>.self, implementation: ServiceAImplDataSource.self, scope: .EagerSingleton)
    Trigger.register(GenericDataSource<ServiceBImpl>.self, implementation: ServiceBImplDataSource.self)
  }
}
