//
//  ServiceBImpl.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

class ServiceBImpl: ServiceB {
  
  weak var serviceA: ServiceA?

  let serviceC = Trigger.inject(ServiceC) as! ServiceCImpl
  let serviceBImplDataSource = Trigger.inject(GenericDataSource<ServiceBImpl>) as! ServiceBImplDataSource
  
  required init() {
  }
  
  func myCompanyB() -> String {
    return "therapB"
  }
}
