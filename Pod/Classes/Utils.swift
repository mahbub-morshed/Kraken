//
//  Utils.swift
//  Pods
//
//  Created by Syed Sabir Salman on 3/30/16.
//
//

import Foundation

func synchronized<T>(lock: AnyObject?, @noescape closure: () throws -> T) rethrows -> T {
  objc_sync_enter(lock)
  defer {
    objc_sync_exit(lock)
  }
  
  return try closure()
}