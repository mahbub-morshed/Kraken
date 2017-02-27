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


// MARK:- Errors thrown by `Kraken`'s methods.


public enum KrakenError: Error, CustomStringConvertible {

    /**
     Thrown if no matching definition was registered in container.

     - parameter key: definition key used to lookup matching definition
     */
    case definitionNotFound(key: String)

    /**
     Thrown if no factory is registered for definition in container.

     - parameter key: definition key used to lookup matching definition
     */
    case factoryNotFound(key: String)

    /**
     Thrown if actual number of arguments passed to factory does not match
     number of arguments registered.

     - parameter key: definition key used to lookup matching definition
     */
    case argumentCountNotMatched(key: String)

    /**
     Thrown if factory with runtime arguments is registered with a
     Dependency scope of Eager Singleton.

     - parameter key: definition key used to lookup matching definition
     */
    case eagerSingletonNotAllowed(key: String)

    /**
     Thrown if container failed to auto-wire a type.

     - parameters:
     - key: key of definition that failed to be resolved by auto-wiring
     - underlyingError: The error that cause auto-wiring to fail
     */
    case autoWiringFailed(key: String, underlyingError: Error)

    public var description: String {
        switch self {
        case let .definitionNotFound(key):
            return "No object registered for type: \(key). Did you forget to call register:implementation:scope: for type \(key)"
        case let .factoryNotFound(key):
            return "No factory definition is registered for type: \(key)"
        case let .argumentCountNotMatched(key):
            return "Number of arguments expected by factory of type: \(key) does not match with actual arguments passed"
        case let .eagerSingletonNotAllowed(key):
            return "Cannot register factory with runtime arguments for type: \(key). Scope cannot be EagerSingleton."
        case let .autoWiringFailed(key, error):
            return "Failed to auto-wire type: \(key). \(error)"
        }
    }

}
