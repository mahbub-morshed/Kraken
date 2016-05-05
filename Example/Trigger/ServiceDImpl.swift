//
//  ServiceDImpl.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

class ServiceDImpl: ServiceD {
  
  var host: String!
  var port: Int!
  var serviceB: ServiceB!
  
  required init() {
  }
  
  init(host: String, port: Int, serviceB: ServiceB) {
    self.host = host
    self.port = port
    self.serviceB = serviceB
  }

  func myCompanyAddress() -> String {
    return "My company address is \(host):\(port)"
  }
}
