//
//  ServiceEImpl.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 5/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

class ServiceEImpl: ServiceE {

  var serviceA: ServiceA!
  var serviceB: ServiceB!
  var serviceC: ServiceC!

  required init() {
  }

  init(serviceA: ServiceA, serviceB: ServiceB, serviceC: ServiceC) {
    self.serviceA = serviceA
    self.serviceB = serviceB
    self.serviceC = serviceC
  }

  func myDependencyAddresses() -> String {
    return "injected memory addresses are \(unsafeAddressOf(serviceA))  \(unsafeAddressOf(serviceB))  \(unsafeAddressOf(serviceC)))"
  }
}
