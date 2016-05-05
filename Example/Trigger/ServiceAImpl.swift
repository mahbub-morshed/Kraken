//
//  ServiceAImpl.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

class ServiceAImpl: ServiceA {
  
  let serviceB = Trigger.inject(ServiceB) as! ServiceBImpl
  let serviceC = Trigger.inject(ServiceC) as! ServiceCImpl
  let serviceAImplDataSource = Trigger.inject(GenericDataSource<ServiceAImpl>) as! ServiceAImplDataSource
  
  required init() {
  }
  
  func myCompanyA() -> String {
    return "therapA"
  }
}
