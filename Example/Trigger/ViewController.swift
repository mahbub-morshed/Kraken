//
//  Kraken
//
//  Copyright (c) 2016 Syed Sabir Salman-Al-Musawi <sabirvirtuoso@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import Kraken

class ViewController: UIViewController {
  
    let serviceAOne: ServiceA = inject(ServiceA)
    let serviceATwo = ServiceAImpl()
  
    let serviceBOne = ServiceBImpl()
    let serviceBTwo = ServiceBImpl()
  
    let serviceD: ServiceD = inject(ServiceD.self, withArguments: "localhost", 8080)
    let serviceE: ServiceE = inject(ServiceE)
  
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
        print(unsafeAddressOf(serviceAOne))
        print(unsafeAddressOf(serviceAOne.serviceC))
        print(unsafeAddressOf(serviceAOne.serviceC.serviceA!))
        print(unsafeAddressOf(serviceAOne.serviceB))
        print(unsafeAddressOf(serviceAOne.serviceC))
        print(unsafeAddressOf(serviceAOne.serviceB.serviceC))
        print(unsafeAddressOf(serviceBOne.serviceC))
      
        print(unsafeAddressOf(serviceD.serviceB))
        print(unsafeAddressOf(serviceD.serviceB.serviceC))
        print(serviceD.myCompanyAddress())
      
        print(unsafeAddressOf(serviceAOne.serviceB.serviceA!))
        print(unsafeAddressOf(serviceAOne.serviceC.serviceA!))
        print(unsafeAddressOf(serviceAOne.serviceAImplDataSource))
      
        print(unsafeAddressOf(serviceBOne.serviceBImplDataSource))
        print(unsafeAddressOf(serviceBTwo.serviceBImplDataSource))

        print(serviceE.myDependencyAddresses())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

