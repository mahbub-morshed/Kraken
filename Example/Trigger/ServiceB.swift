//
//  ServiceB.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

protocol ServiceB: Injectable {

  weak var serviceA: ServiceA? { get set }

  var serviceC: ServiceC { get set }

  var serviceBImplDataSource: GenericDataSource<ServiceBImpl> { get set }

  func myCompanyB() -> String

}
