//
//  ServiceCImpl.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

class ServiceCImpl: ServiceC {
  
  weak var serviceA: ServiceA?

  required init() {
  }
  
  func myCompanyC() -> String {
    return "therapC"
  }

}
