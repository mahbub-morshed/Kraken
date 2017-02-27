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


/// MARK:- Custom Dependency Container (Dependency injection by AutoWiring)


extension Kraken {

  public static func resolveByAutoWiring(_ typeToInject: Any, tag: DependencyTagConvertible? = nil) throws -> Injectable? {
    let definitionKey = prepareDefinitionKey(forInterface: typeToInject, andTag: tag)
    let resolvedInstance: Injectable?

    let dependencyDefinition: DependencyDefinition! = definitionMap[definitionKey]

    guard isAutoWiringSupported(forDefinition: dependencyDefinition) else {
      return nil
    }

    do {
      resolvedInstance = try dependencyDefinition.autoWiringFactory!()
    }
    catch {
      throw KrakenError.autoWiringFailed(key: definitionKey, underlyingError: error)
    }

    return resolvedInstance
  }

  fileprivate static func isAutoWiringSupported(forDefinition definition: DependencyDefinition) -> Bool {
    return definition.numberOfArguments > 0 && definition.autoWiringFactory != nil
  }

}
