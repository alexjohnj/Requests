//
// Created by Alex Jackson on 2018-12-23.
//

import Foundation

/// A `String` wrapper that implements case insensitive comparison, sorting and hashing methods.
public struct CaseInsensitiveString: CustomStringConvertible {

    // MARK: - Public Properties

    public var description: String {
        return _string
    }

    // MARK: - Private Properties

    private let _string: String

    // MARK: - Initializers

    public init(_ string: String) {
        self._string = string
    }
}

// MARK: - String Literal Conformance

extension CaseInsensitiveString: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

// MARK: - Equatable Conformance

extension CaseInsensitiveString: Equatable {
    public static func == (lhs: CaseInsensitiveString, rhs: CaseInsensitiveString) -> Bool {
        return lhs._string.lowercased() == rhs._string.lowercased()
    }
}

// MARK: - Hashable Conformance

extension CaseInsensitiveString: Hashable {

    public func hash(into hasher: inout Hasher) {
        _string.lowercased().hash(into: &hasher)
    }
}

// MARK: - Comparable Conformance

extension CaseInsensitiveString: Comparable {
    public static func < (lhs: CaseInsensitiveString, rhs: CaseInsensitiveString) -> Bool {
        return lhs._string.lowercased() < rhs._string.lowercased()
    }
}
