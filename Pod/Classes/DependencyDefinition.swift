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

import Foundation


/// MARK:- ImplementationDefinition subclass for registering dummy implementations or implementation types


public final class ImplementationDefinition: DependencyDefinition {

    var implementationType: Injectable.Type?
    var implementation: Injectable?

    init(scope: DependencyScope, implementationType: Injectable.Type? = nil, implementation: Injectable? = nil, completionHandler: ((Injectable) -> ())? = nil) {
        self.implementationType = implementationType
        self.implementation = implementation
        super.init(scope: scope, completionHandler: completionHandler)
    }

}


/// MARK:- FactoryDefinition subclass for registering dependency factory


public final class FactoryDefinition<F>: DependencyDefinition {

    var factory: F

    init(scope: DependencyScope, factory: F, numberOfArguments: Int = 0, completionHandler: ((Injectable) -> ())? = nil) {
        self.factory = factory
        super.init(scope: scope, numberOfArguments: numberOfArguments, completionHandler: completionHandler)
    }

}


/// MARK:- Base class for registering dependency information


open class DependencyDefinition {

    var scope: DependencyScope
    var numberOfArguments: Int
    var completionHandler: ((Injectable) -> ())?
    var autoWiringFactory: (() throws -> Injectable?)?

    init(scope: DependencyScope, numberOfArguments: Int = 0, completionHandler: ((Injectable) -> ())? = nil) {
        self.scope = scope
        self.numberOfArguments = numberOfArguments
        self.completionHandler = completionHandler
    }

}
