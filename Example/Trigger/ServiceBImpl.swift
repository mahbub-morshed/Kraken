//
//  ServiceBImpl.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

class ServiceBImpl: ServiceB {
  
  weak var serviceA: ServiceA?

  var serviceC: ServiceC = inject(ServiceC)
  var serviceBImplDataSource: GenericDataSource<ServiceBImpl> = inject(GenericDataSource<ServiceBImpl>)
  
  required init() {
  }
  
  func myCompanyB() -> String {
    return "therapB"
  }

}
