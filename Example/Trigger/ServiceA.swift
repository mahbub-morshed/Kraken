//
//  ServiceA.swift
//  Trigger
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

protocol ServiceA: Injectable {
  func myCompanyA() -> String
}