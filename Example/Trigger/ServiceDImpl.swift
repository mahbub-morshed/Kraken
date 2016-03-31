//
//  ServiceDImpl.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Trigger

class ServiceDImpl: ServiceD {
  
  let serviceB = Trigger.inject(ServiceB) as! ServiceBImpl
  
  required init() {
  }
  
  func myCompanyD() -> String {
    return "therapD"
  }
}
