//
//  DependencyConfigurator.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/31/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Kraken

class DependencyConfigurator {

  static func bootstrapDependencies() {
    Kraken.register(ServiceA.self, implementationType: ServiceAImpl.self, scope: .Singleton)
    Kraken.register(ServiceB.self, implementationType: ServiceBImpl.self, scope: .Singleton) {
      (resolvedInstance: Injectable) -> () in

      let serviceB = resolvedInstance as! ServiceBImpl
      serviceB.serviceA = Kraken.injectWeak(ServiceA).value as! ServiceAImpl
    }

    Kraken.register(ServiceC.self, implementationType: ServiceCImpl.self, scope: .Singleton) {
      (resolvedInstance: Injectable) -> () in

      let serviceC = resolvedInstance as! ServiceCImpl
      serviceC.serviceA = Kraken.injectWeak(ServiceA).value as! ServiceAImpl
    }

    Kraken.register(ServiceD.self) {
      ServiceDImpl(host: $0, port: $1, serviceB: Kraken.inject(ServiceB) as! ServiceBImpl) as ServiceD
    }

    Kraken.register(GenericDataSource<ServiceAImpl>.self, implementationType: ServiceAImplDataSource.self, scope: .EagerSingleton)
    Kraken.register(GenericDataSource<ServiceBImpl>.self, implementationType: ServiceBImplDataSource.self, scope: .Singleton)

    Kraken.register(ServiceE.self) {
        ServiceEImpl(serviceA: $0, serviceB: $1, serviceC: $2)
    }
  }
}
