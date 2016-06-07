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

import Kraken

class DependencyConfigurator {

  static func bootstrapDependencies() {
    Kraken.register(ServiceA.self, implementationType: ServiceAImpl.self, scope: .Singleton)
    Kraken.register(ServiceB.self, implementationType: ServiceBImpl.self, scope: .Singleton) {
      (resolvedInstance: Injectable) -> () in

      let serviceB = resolvedInstance as! ServiceBImpl
      serviceB.serviceA = injectWeak(ServiceA).value as! ServiceAImpl
    }

    Kraken.register(ServiceC.self, implementationType: ServiceCImpl.self, scope: .Singleton) {
      (resolvedInstance: Injectable) -> () in

      let serviceC = resolvedInstance as! ServiceCImpl
      serviceC.serviceA = injectWeak(ServiceA).value as! ServiceAImpl
    }

    try! Kraken.register(ServiceD.self) {
      ServiceDImpl(host: $0, port: $1, serviceB: inject(ServiceB)) as ServiceD
    }

    Kraken.register(GenericDataSource<ServiceAImpl>.self, implementationType: ServiceAImplDataSource.self, scope: .EagerSingleton)
    Kraken.register(GenericDataSource<ServiceBImpl>.self, implementationType: ServiceBImplDataSource.self, scope: .Singleton)

    try! Kraken.register(ServiceE.self) {
        ServiceEImpl(serviceA: $0, serviceB: $1, serviceC: $2)
    }
  }

}
