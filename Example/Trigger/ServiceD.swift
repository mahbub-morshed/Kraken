//
//  ServiceD.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

protocol ServiceD: Injectable {

  var serviceB: ServiceB! { get set }

  func myCompanyAddress() -> String

}
