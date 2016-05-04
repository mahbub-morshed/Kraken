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
    Trigger.register(ServiceA.self, implementationType: ServiceAImpl.self, scope: .Singleton)
    //Trigger.register(ServiceA.self) { ServiceAImpl() as ServiceA }
    Trigger.register(ServiceB.self, implementationType: ServiceBImpl.self, scope: .Singleton) {
      (resolvedInstance: Injectable) -> () in

      let serviceB = resolvedInstance as! ServiceBImpl
      serviceB.serviceA = Trigger.injectWeak(ServiceA).value as! ServiceAImpl
    }
    
    Trigger.register(ServiceC.self, implementationType: ServiceCImpl.self, scope: .Singleton) {
      (resolvedInstance: Injectable) -> () in

      let serviceC = resolvedInstance as! ServiceCImpl
      serviceC.serviceA = Trigger.injectWeak(ServiceA).value as! ServiceAImpl
    }
    
    Trigger.register(GenericDataSource<ServiceAImpl>.self, implementationType: ServiceAImplDataSource.self, scope: .EagerSingleton)
    Trigger.register(GenericDataSource<ServiceBImpl>.self, implementationType: ServiceBImplDataSource.self, scope: .Singleton)
  }
}
