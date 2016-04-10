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
    Trigger.register(ServiceA.self, implementationType: ServiceAImpl.self)
    Trigger.register(ServiceB.self, implementationType: ServiceBImpl.self)
    
    Trigger.register(ServiceC.self, implementationType: ServiceCImpl.self, scope: .Singleton)
    
    Trigger.register(GenericDataSource<ServiceAImpl>.self, implementationType: ServiceAImplDataSource.self, scope: .EagerSingleton)
    Trigger.register(GenericDataSource<ServiceBImpl>.self, implementationType: ServiceBImplDataSource.self, scope: .Singleton)
  }
}
