//
//  Kraken
//
//  Copyright (c) 2017 Syed Sabir Salman-Al-Musawi <sabirvirtuoso@gmail.com>
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


/**
 Use a tag in case you need to register multiple factories of the same type,
 to differentiate them. Tags can be either String or Int, to your convenience.
 */

public enum Tag: Equatable {

    case String(StringLiteralType)

    case Int(IntegerLiteralType)

}

public func ==(lhs: Tag, rhs: Tag) -> Bool {
    switch (lhs, rhs) {
        case let (.String(lhsString), .String(rhsString)):
            return lhsString == rhsString
        case let (.Int(lhsInt), .Int(rhsInt)):
            return lhsInt == rhsInt
        default:
            return false
    }
}


/**
 Implement this protocol on your type if you want to use its instances as `Kraken`'s tags. `Tag`, `String`, `Int`
 and any `RawRepresentable` with `RawType` of `String` or `Int` by default conform to this protocol.
 */

public protocol DependencyTagConvertible {
    var dependencyTag: Tag { get }
}


/// MARK: - `Tag` extension for DependencyTagConvertible implementation

extension Tag: DependencyTagConvertible {
    public var dependencyTag: Tag {
        return self
    }
}


/// MARK: - `String` extension for DependencyTagConvertible implementation

extension String: DependencyTagConvertible {
    public var dependencyTag: Tag {
        return .String(self)
    }
}


/// MARK: - `Int` extension for DependencyTagConvertible implementation

extension Int: DependencyTagConvertible {
    public var dependencyTag: Tag {
        return .Int(self)
    }
}


/// MARK: - Extension of `RawRepresentable` with `RawType` Int for DependencyTagConvertible implementation

extension DependencyTagConvertible where Self: RawRepresentable, Self.RawValue == Int {
    public var dependencyTag: Tag {
        return .Int(rawValue)
    }
}


/// MARK: - Extension of `RawRepresentable` with `RawType` String for DependencyTagConvertible implementation

extension DependencyTagConvertible where Self: RawRepresentable, Self.RawValue == String {
    public var dependencyTag: Tag {
        return .String(rawValue)
    }
}
