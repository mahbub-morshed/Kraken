//
//  ServiceBImpl.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

class ServiceBImpl: ServiceB {
  
  let serviceC = DependencyContainer.inject(ServiceC) as! ServiceCImpl
  let serviceBImplDataSource = DependencyContainer.inject(GenericDataSource<ServiceBImpl>) as! ServiceBImplDataSource
  
  required init() {
  }
  
  func myCompanyB() -> String {
    return "therapB"
  }
}
