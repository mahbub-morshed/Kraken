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
}

public enum ServiceTypeNumber: Int, DependencyTagConvertible {
    case Normal = 0, VIP
}

public enum ServiceTypeString: String, DependencyTagConvertible {
    case Normal = "Normal", VIP = "VIP"
}

private class ServiceImp1: Service {
    required init() {
    }
}

private class ServiceImp2: Service {
    required init() {
    }
}

private protocol Server: Injectable {
    weak var client: Client? { get set }
    weak var secondClient: Client? { get set }
}

private protocol Client: Injectable {
    var server: Server { get set }
    var secondServer: Server { get set }
}

class KrakenTests: XCTestCase {

    override func setUp() {
        Kraken.reset()
    }

    func testThatItResolvesDependencyRegisteredWithSingleImplementation() {
        // given
        Kraken.register(Service.self, implementation: ServiceImp2())

        // when
        let serviceInstance: Service = inject(Service.self)

        // then
        XCTAssertTrue(serviceInstance is ServiceImp2)

        // and when
        let optService: Service? = inject(Service.self)

        // then
        XCTAssertTrue(optService is ServiceImp2)

        // and when
        let impService: Service! = inject(Service.self)

        // then
        XCTAssertTrue(impService is ServiceImp2)
    }

    func testThatItResolvesDependencyRegisteredWithMultipleImplementationsWithTags() {
        // given
        Kraken.register(Service.self, tag: ServiceTypeNumber.Normal, implementation: ServiceImp1())
        Kraken.register(Service.self, tag: ServiceTypeNumber.VIP, implementation: ServiceImp2())

        // when
        let serviceInstanceOne: Service = inject(Service.self, tag: ServiceTypeNumber.Normal)

        // then
        XCTAssertTrue(serviceInstanceOne is ServiceImp1)

        // and when
        let serviceInstanceTwo: Service = inject(Service.self, tag: ServiceTypeNumber.VIP)

        // then
        XCTAssertTrue(serviceInstanceTwo is ServiceImp2)

        // and when
        let optService: Service? = inject(Service.self, tag: ServiceTypeNumber.Normal)

        // then
        XCTAssertTrue(optService is ServiceImp1)

        // and when
        let impService: Service! = inject(Service.self, tag: ServiceTypeNumber.VIP)

        // then
        XCTAssertTrue(impService is ServiceImp2)
    }

    func testThatItResolvesDependencyRegisteredWithMultipleImplementationsWithAndWithoutTag() {
        // given
        Kraken.register(Service.self, tag: ServiceTypeNumber.Normal, implementation: ServiceImp1())
        Kraken.register(Service.self, implementation: ServiceImp2())

        // when
        let serviceInstanceOne: Service = inject(Service.self, tag: ServiceTypeNumber.Normal)

        // then
        XCTAssertTrue(serviceInstanceOne is ServiceImp1)

        // and when
        let serviceInstanceTwo: Service = inject(Service.self)

        // then
        XCTAssertTrue(serviceInstanceTwo is ServiceImp2)

        // and when
        let optService: Service? = inject(Service.self, tag: ServiceTypeNumber.Normal)

        // then
        XCTAssertTrue(optService is ServiceImp1)

        // and when
        let impService: Service! = inject(Service.self)

        // then
        XCTAssertTrue(impService is ServiceImp2)
    }

    func testThatItResolvesDependencyRegisteredWithSingleImplementationType() {
        // given
        Kraken.register(Service.self, implementationType: ServiceImp1.self)

        // when
        let serviceInstance: Service = inject(Service.self)

        // then
        XCTAssertTrue(serviceInstance is ServiceImp1)

        // and when
        let optService: Service? = inject(Service.self)

        // then
        XCTAssertTrue(optService is ServiceImp1)

        // and when
        let impService: Service! = inject(Service.self)

        // then
        XCTAssertTrue(impService is ServiceImp1)
    }

    func testThatItResolvesDependencyRegisteredWithMultipleImplementationTypesWithTags() {
        // given
        Kraken.register(Service.self, tag: ServiceTypeString.Normal, implementationType: ServiceImp1.self)
        Kraken.register(Service.self, tag: ServiceTypeString.VIP, implementationType: ServiceImp2.self)

        // when
        let serviceInstanceOne: Service = inject(Service.self, tag: ServiceTypeString.Normal)

        // then
        XCTAssertTrue(serviceInstanceOne is ServiceImp1)

        // and when
        let serviceInstanceTwo: Service = inject(Service.self, tag: ServiceTypeString.VIP)

        // then
        XCTAssertTrue(serviceInstanceTwo is ServiceImp2)

        // and when
        let optService: Service? = inject(Service.self, tag: ServiceTypeString.Normal)

        // then
        XCTAssertTrue(optService is ServiceImp1)

        // and when
        let impService: Service! = inject(Service.self, tag: ServiceTypeString.VIP)

        // then
        XCTAssertTrue(impService is ServiceImp2)
    }

    func testThatItResolvesDependencyRegisteredWithMultipleImplementationTypesWithAndWithoutTags() {
        // given
        Kraken.register(Service.self, tag: ServiceTypeString.Normal, implementationType: ServiceImp1.self)
        Kraken.register(Service.self, implementationType: ServiceImp2.self)

        // when
        let serviceInstanceOne: Service = inject(Service.self, tag: ServiceTypeString.Normal)

        // then
        XCTAssertTrue(serviceInstanceOne is ServiceImp1)

        // and when
        let serviceInstanceTwo: Service = inject(Service.self)

        // then
        XCTAssertTrue(serviceInstanceTwo is ServiceImp2)

        // and when
        let optService: Service? = inject(Service.self, tag: ServiceTypeString.Normal)

        // then
        XCTAssertTrue(optService is ServiceImp1)

        // and when
        let impService: Service! = inject(Service.self)

        // then
        XCTAssertTrue(impService is ServiceImp2)
    }

    func testThatNewRegistrationWithoutTagOverridesPreviousRegistration() {
        // given
        Kraken.register(Service.self, implementation: ServiceImp1())
        let service1: Service = inject(Service.self)

        // when
        Kraken.register(Service.self, implementation: ServiceImp2())
        let service2: Service = inject(Service.self)

        // then
        XCTAssertTrue(service1 is ServiceImp1)
        XCTAssertTrue(service2 is ServiceImp2)
    }

    func testThatNewRegistrationWithTagOverridesPreviousRegistration() {
        // given
        Kraken.register(Service.self, tag: ServiceTypeNumber.Normal, implementation: ServiceImp1())
        let service1: Service = inject(Service.self, tag: ServiceTypeNumber.Normal)

        // when
        Kraken.register(Service.self, tag: ServiceTypeNumber.Normal, implementation: ServiceImp2())
        let service2: Service = inject(Service.self, tag: ServiceTypeNumber.Normal)

        // then
        XCTAssertTrue(service1 is ServiceImp1)
        XCTAssertTrue(service2 is ServiceImp2)
    }

    func testThatItThrowsErrorIfCanNotFindDefinitionForType() {
        // given
        Kraken.register(ServiceImp1.self, implementation: ServiceImp1())

        // when
        AssertThrows(expression: try Kraken.inject(Service.self)) { error in
            guard case let KrakenError.definitionNotFound(key) = error else {
                return false
            }

            // then
            let expectedKey = String(describing: Service.self)
            XCTAssertEqual(key, expectedKey)

            return true
        }
    }

    func testThatItThrowsErrorIfCanNotFindDefinitionForFactoryWithOneArgument() {
        // given
        Kraken.register(ServiceImp1.self, implementation: ServiceImp1())

        // when
        AssertThrows(expression: try Kraken.inject(Service.self, withArguments: "some argument")) { error in
            guard case let KrakenError.definitionNotFound(key) = error else {
                return false
            }

            // then
            let expectedKey = String(describing: Service.self)
            XCTAssertEqual(key, expectedKey)

            return true
        }
    }

    func testThatItThrowsErrorIfCanNotFindDefinitionForFactoryWithTwoArguments() {
        // given
        Kraken.register(ServiceImp1.self, implementation: ServiceImp1())

        // when
        AssertThrows(expression: try Kraken.inject(Service.self, withArguments: "some argument one", "some argument two")) { error in
            guard case let KrakenError.definitionNotFound(key) = error else {
                return false
            }

            // then
            let expectedKey = String(describing: Service.self)
            XCTAssertEqual(key, expectedKey)

            return true
        }
    }

    func testThatItThrowsErrorIfCanNotFindDefinitionForFactoryWithThreeArguments() {
        // given
        Kraken.register(ServiceImp1.self, implementation: ServiceImp1())

        // when
        AssertThrows(expression: try Kraken.inject(Service.self, withArguments: "some argument one", "some argument two", "some argument three")) { error in
            guard case let KrakenError.definitionNotFound(key) = error else {
                return false
            }

            // then
            let expectedKey = String(describing: Service.self)
            XCTAssertEqual(key, expectedKey)

            return true
        }
    }

    func testThatItRemovesDependencyDefinitionWithoutTagSuccessfully() {
        // given
        Kraken.register(ServiceImp1.self, implementation: ServiceImp1())

        // when
        Kraken.remove(ServiceImp1.self)

        // then
        XCTAssertFalse(Kraken.definitionExists(forKey: String(describing: ServiceImp1.self)))
    }

    func testThatItRemovesDependencyDefinitionWithTagSuccessfully() {
        // given
        Kraken.register(ServiceImp1.self, tag: ServiceTypeString.Normal, implementation: ServiceImp1())

        // when
        Kraken.remove(ServiceImp1.self, tag: ServiceTypeString.Normal)

        // then
        XCTAssertFalse(Kraken.definitionExists(forKey: String(describing: ServiceImp1.self) + String(describing: ServiceTypeString.Normal)))
    }

    func testThatItResolvesCircularDependencies() {
        // given

        class ResolvableServer: Server {
            weak var client: Client?
            weak var secondClient: Client?

            required init() {
            }

        }

        class ResolvableClient: Client {
            var server: Server = inject(Server.self)
            var secondServer: Server = inject(Server.self)

            required init() {
            }

        }

        Kraken.register(Client.self, implementationType: ResolvableClient.self, scope: .singleton)

        Kraken.register(Server.self, implementationType: ResolvableServer.self, scope: .singleton) {
            (resolvedInstance: Injectable) -> () in

            let resolvableServer = resolvedInstance as! ResolvableServer
            resolvableServer.client = injectWeak(Client.self).value as! ResolvableClient
            resolvableServer.secondClient = injectWeak(Client.self).value as! ResolvableClient
        }

        // when
        let client: Client = inject(Client.self)
        let server: Server = inject(Server.self)

        // then
        XCTAssertTrue(server === client.server)
        XCTAssertTrue(server === client.secondServer)
        XCTAssertTrue(client === client.server.client!)
        XCTAssertTrue(client === client.server.secondClient!)
    }

}
