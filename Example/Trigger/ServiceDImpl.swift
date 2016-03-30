//
//  ServiceDImpl.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

class ServiceDImpl: ServiceD {
  
  let serviceB = DependencyContainer.inject(ServiceB) as! ServiceBImpl
  
  required init() {
  }
  
  func myCompanyD() -> String {
    return "therapD"
  }
}
