//
//  ServiceAImpl.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

class ServiceAImpl: ServiceA {
  
  let serviceB = Kraken.inject(ServiceB) as! ServiceBImpl
  let serviceC = Kraken.inject(ServiceC) as! ServiceCImpl
  let serviceAImplDataSource = Kraken.inject(GenericDataSource<ServiceAImpl>) as! ServiceAImplDataSource
  
  required init() {
  }
  
  func myCompanyA() -> String {
    return "therapA"
  }
}
