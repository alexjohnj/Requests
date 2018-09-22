//
//  HTTPHeader.swift
//  Requests
//
//  Created by Alex Jackson on 22/09/2018.
//

/// A header field in a HTTP request. A field consists of a key-value pair mapping `name` onto `value`.
public struct HTTPHeader: Hashable, CustomStringConvertible {

    /// The name of a header in a HTTP request.
    public struct Name: Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {

        public let rawValue: String

        public var description: String {
            return rawValue
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }

        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }
    }

    public let name: Name

    public let value: String

    public var description: String {
        return "\(name): \(value)"
    }

    public init(name: Name, value: String) {
        self.name = name
        self.value = value
    }
}

extension HTTPHeader {
    public var explode: (name: Name, value: String) {
        return (self.name, self.value)
    }
}

extension HTTPHeader {
    public static func ~= (pattern: HTTPHeader, value: HTTPHeader) -> Bool {
        return pattern == value
    }
}

public extension HTTPHeader.Name {

    static let contentType: HTTPHeader.Name = "Content-Type"

}

public extension HTTPHeader {

    static let contentType: (String) -> HTTPHeader = { value in
        return HTTPHeader(name: .contentType, value: value)
    }

}
