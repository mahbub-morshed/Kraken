//
//  ServiceAImpl.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

class ServiceAImpl: ServiceA {
  
  var serviceB: ServiceB = inject(ServiceB)
  var serviceC: ServiceC = inject(ServiceC)
  var serviceAImplDataSource: GenericDataSource<ServiceAImpl> = inject(GenericDataSource<ServiceAImpl>)
  
  required init() {
  }
  
  func myCompanyA() -> String {
    return "therapA"
  }

}
