//
//  ServiceE.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 5/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
import Kraken

protocol ServiceE: Injectable {
  func myDependencyAddresses() -> String
}