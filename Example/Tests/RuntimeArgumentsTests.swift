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

private protocol Service: Injectable {
  var name: String! { get }
}

private class ServiceImp: Service {

  var name: String!

  required init() {}

  init(name: String, baseURL: String, port: Int) {
    self.name = name
  }

}

private class ServiceImp1: Service {
  let name: String! = "ServiceImp1"

  required init() {}
}

private class ServiceImp2: Service {
  let name: String! = "ServiceImp2"

  required init() {}
}

class RuntimeArgumentsTests: XCTestCase {

  override func setUp() {
    Kraken.reset()
  }

  func testThatItResolvesInstanceWithNoArgument() {
    // given
    Kraken.register(Service.self, factory: { ServiceImp1() as Service })

    // when
    let service: Service = inject(Service)

    // then
    XCTAssertTrue(service is ServiceImp1)
  }

  func testThatItResolvesInstanceWithOneArgument() {
    // given
    let arg1 = 1

    try! Kraken.register(Service.self) { (a1: Int) -> Injectable in
      XCTAssertEqual(a1, arg1)

      return ServiceImp1() as Service
    }

    // when
    let service: Service = inject(Service.self, withArguments: arg1)

    // then
    XCTAssertTrue(service is ServiceImp1)
  }

  func testThatItResolvesInstanceWithTwoArguments() {
    // given
    let arg1 = 1, arg2 = 2

    try! Kraken.register(Service.self) { (a1: Int, a2: Int) -> Injectable in
      XCTAssertEqual(a1, arg1)
      XCTAssertEqual(a2, arg2)

      return ServiceImp1() as Service
    }

    // when
    let service: Service = inject(Service.self, withArguments: arg1, arg2)

    // then
    XCTAssertTrue(service is ServiceImp1)
  }

  func testThatItResolvesInstanceWithThreeArguments() {
    // given
    let arg1 = 1, arg2 = 2, arg3 = 3

    try! Kraken.register(Service.self) { (a1: Int, a2: Int, a3: Int) -> Injectable in
      XCTAssertEqual(a1, arg1)
      XCTAssertEqual(a2, arg2)
      XCTAssertEqual(a3, arg3)

      return ServiceImp1() as Service
    }

    //when
    let service: Service = inject(Service.self, withArguments: arg1, arg2, arg3)

    //then
    XCTAssertTrue(service is ServiceImp1)
  }

  func testThatItThrowsErrorIfFactoryIsNotRegisteredForDefinitionWithRuntimeArguments() {
    //given
    let arg1 = 1

    Kraken.register(Service.self, implementation: ServiceImp1())

    //when
    AssertThrows(expression: try Kraken.inject(Service.self, withArguments: arg1)) { error in
      guard case let KrakenError.FactoryNotFound(key) = error else { return false }

      //then
      let expectedKey = String(Service.self)
      XCTAssertEqual(key, expectedKey)

      return true
    }
  }

  func testThatItThrowsErrorIfNumberOfArgumentsAtRuntimeMismatchesThatOfRegisteredFactory() {
    //given
    let arg1 = 1, arg2 = "string"

    try! Kraken.register(Service.self) { (a1: Int) -> Injectable in ServiceImp1() as Service }

    //when
    AssertThrows(expression: try Kraken.inject(Service.self, withArguments: arg1, arg2)) { error in
      guard case let KrakenError.ArgumentCountNotMatched(key) = error else { return false }

      //then
      let expectedKey = String(Service.self)
      XCTAssertEqual(key, expectedKey)

      return true
    }
  }

}
