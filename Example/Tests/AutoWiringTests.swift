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

import XCTest
@testable import Kraken

private protocol ServiceA: Injectable {}
private protocol ServiceB: Injectable {}
private protocol AutoWiredService: Injectable {
  var serviceA: ServiceA! { get set }
  var serviceB: ServiceB! { get set }
}

private class ServiceAImpl: ServiceA {
  required init() {}
}
private class ServiceBImpl: ServiceB {
  required init() {}
}

private class AutoWiredServiceImpl: AutoWiredService {

  var serviceA: ServiceA!
  var serviceB: ServiceB!

  required init() {
  }

  init(serviceA: ServiceA, serviceB: ServiceB) {
    self.serviceA = serviceA
    self.serviceB = serviceB
  }

}

class AutoWiringTests: XCTestCase {

  override func setUp() {
    Kraken.reset()
  }

  func testThatItCanResolveWithAutoWiring() {
    // given
    Kraken.register(ServiceA.self, implementationType: ServiceAImpl.self)
    Kraken.register(ServiceB.self, implementationType: ServiceBImpl.self)

    try! Kraken.register(AutoWiredService.self) {
      AutoWiredServiceImpl(serviceA: $0, serviceB: $1) as AutoWiredService
    }

    // when
    let service: AutoWiredService = inject(AutoWiredService.self)

    // then
    XCTAssert(service is AutoWiredServiceImpl)

    let serviceA = service.serviceA
    XCTAssertTrue(serviceA is ServiceAImpl)

    let serviceB = service.serviceB
    XCTAssertTrue(serviceB is ServiceBImpl)
  }

  func testThatAutoWiringIsNotSupportedIfNoFactoryWithArgumentIsRegistered() {
    // given
    Kraken.register(ServiceA.self, factory: { ServiceAImpl() as ServiceA })

    // when
    let serviceA = try! Kraken.resolveByAutoWiring(ServiceA.self)

    // then
    XCTAssertNil(serviceA)
  }

  func testThatAutoWiringIsNotSupportedIfAutoWiringFactoryIsNilDueToMissingDependency() {
    // given
    Kraken.register(ServiceA.self, implementationType: ServiceAImpl.self)

    try! Kraken.register(AutoWiredService.self) {
      AutoWiredServiceImpl(serviceA: $0, serviceB: $1) as AutoWiredService
    }

    // when
    let service = try! Kraken.resolveByAutoWiring(AutoWiredService.self)

    // then
    XCTAssertNil(service)
  }

  func testThatAutoWiringThrowsErrorIfAutoWiringFails() {
    // given
    Kraken.register(ServiceA.self, implementationType: ServiceAImpl.self)
    Kraken.register(ServiceB.self, implementationType: ServiceBImpl.self)

    try! Kraken.register(AutoWiredService.self) {
      AutoWiredServiceImpl(serviceA: $0, serviceB: $1) as AutoWiredService
    }

    Kraken.remove(ServiceA.self)

    // when
    AssertThrows(expression: try Kraken.resolveByAutoWiring(AutoWiredService.self)) { error in
      guard case let KrakenError.autoWiringFailed(key, _) = error else { return false }

      // then
      let expectedKey = String(describing: AutoWiredService.self)
      XCTAssertEqual(key, expectedKey)

      return true
    }
  }

}
