//
//  GenericDataSource.swift
//  Kraken
//
//  Created by Syed Sabir Salman on 3/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

class GenericDataSource<T> {
  
  var items: [T] {
    get {
      return itemList
    }
  }
  
  private var itemList = [T]()
  
  func setItems(items: [T]) {
    itemList = items
  }
}