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

  let serviceC = Kraken.inject(ServiceC) as! ServiceCImpl
  let serviceBImplDataSource = Kraken.inject(GenericDataSource<ServiceBImpl>) as! ServiceBImplDataSource
  
  required init() {
  }
  
  func myCompanyB() -> String {
    return "therapB"
  }
}
