//
//  ServiceC.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

protocol ServiceC: Injectable {

  weak var serviceA: ServiceA? { get set }

  func myCompanyC() -> String

}
