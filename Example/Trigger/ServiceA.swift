//
//  ServiceA.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

protocol ServiceA: Injectable {

  var serviceB: ServiceB { get set }

  var serviceC: ServiceC { get set }

  var serviceAImplDataSource: GenericDataSource<ServiceAImpl> { get set }

  func myCompanyA() -> String

}