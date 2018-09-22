//
// Created by Alex Jackson on 01/09/2018.
//

/// A method (AKA verb) to be sent in a HTTP request. The standard (HTTP/1.1) headers are implemented as static
/// properties. New methods can be added in an extension on the `HTTPMethod` type.
///
/// # Pattern Matching
///
/// `HTTPMethod` provides an overload of the `~=` operator so methods can esaily be pattern matched on in a `switch`
/// statement.
///
public struct HTTPMethod: Hashable, RawRepresentable {

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - Pattern Matching

public extension HTTPMethod {
    static func ~= (pattern: HTTPMethod, value: HTTPMethod) -> Bool {
        return pattern == value
    }
}

// MARK: - ExpressibleByStringLiteral Conformance

extension HTTPMethod: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: - HTTP/1.1 Methods

public extension HTTPMethod {

    static let connect: HTTPMethod = "CONNECT"

    static let delete: HTTPMethod = "DELETE"

    static let get: HTTPMethod = "GET"

    static let head: HTTPMethod = "HEAD"

    static let options: HTTPMethod = "OPTIONS"

    static let patch: HTTPMethod = "PATCH"

    static let post: HTTPMethod = "POST"

    static let put: HTTPMethod = "PUT"

    static let trace: HTTPMethod = "TRACE"
}
