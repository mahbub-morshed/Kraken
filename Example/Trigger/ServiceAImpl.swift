//
//  ServiceAImpl.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

class ServiceAImpl: ServiceA {
  
  let serviceB = DependencyContainer.inject(ServiceB) as! ServiceBImpl
  let serviceAImplDataSource = DependencyContainer.inject(GenericDataSource<ServiceAImpl>) as! ServiceAImplDataSource
  
  required init() {
  }
  
  func myCompanyA() -> String {
    return "therapA"
  }
}
