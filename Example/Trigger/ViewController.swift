//
//  ViewController.swift
//  Trigger
//
//  Created by Syed Sabir Salman-Al-Musawi on 03/29/2016.
//  Copyright (c) 2016 Syed Sabir Salman-Al-Musawi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
    let serviceAOne = ServiceAImpl()
    let serviceATwo = ServiceAImpl()
  
    let serviceBOne = ServiceBImpl()
    let serviceBTwo = ServiceBImpl()
  
    let serviceD = ServiceDImpl()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        generateDataSourceItems()
        showReferenceAddress()
    }
  
    private func generateDataSourceItems() {
        serviceAOne.serviceAImplDataSource.setItems([ServiceAImpl(), ServiceAImpl(), ServiceAImpl()])
  
        serviceBOne.serviceBImplDataSource.setItems([ServiceBImpl(), ServiceBImpl(), ServiceBImpl(), ServiceBImpl()])
    }
  
    private func showReferenceAddress() {
        print(unsafeAddressOf(serviceAOne.serviceB))
        print(unsafeAddressOf(serviceAOne.serviceC))
        print(unsafeAddressOf(serviceAOne.serviceB.serviceC))
        print(unsafeAddressOf(serviceBOne.serviceC))
      
        print(unsafeAddressOf(serviceD.serviceB))
        print(unsafeAddressOf(serviceD.serviceB.serviceC))
      
        print(unsafeAddressOf(serviceAOne.serviceB.serviceA!))
        print(unsafeAddressOf(serviceAOne.serviceC.serviceA!))
        print(unsafeAddressOf(serviceAOne.serviceAImplDataSource))
      
        print(unsafeAddressOf(serviceBOne.serviceBImplDataSource))
        print(unsafeAddressOf(serviceBTwo.serviceBImplDataSource))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

