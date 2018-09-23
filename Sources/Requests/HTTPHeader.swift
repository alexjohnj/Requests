//
//  HTTPHeader.swift
//  Requests
//
//  Created by Alex Jackson on 22/09/2018.
//

/// A header field in a HTTP request. A field consists of a key-value pair mapping `name` onto `value`.
///
/// # Equatable & Hashable Conformance
///
/// As HTTP headers are case insensitive, the implementations of `Hashable` and `Equatable` take this into consideration
/// and convert all header names to lowercase before comparing them.
///
public struct HTTPHeader {

    // MARK: - Nested Types

    /// The name of a header in a HTTP request.
    public struct Name: Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {

        // MARK: - Public Properties

        public let rawValue: String

        public var description: String {
            return rawValue
        }

        // MARK: - Initializers

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }

        public init(stringLiteral value: String) {
            self.init(rawValue: value)
        }

        // MARK: - Equatable Conformance

        public static func == (lhs: Name, rhs: Name) -> Bool {
            return lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(rawValue.lowercased())
        }
    }

    // MARK: - Public Properties

    public let name: Name

    public let value: String

    // MARK: - Initializers

    public init(name: Name, value: String) {
        self.name = name
        self.value = value
    }
}

// MARK: - CustomStringConvertible Conformance

extension HTTPHeader: CustomStringConvertible {
    public var description: String {
        return "\(name): \(value)"
    }
}

// MARK: - Equatable Conformance

extension HTTPHeader: Equatable { }

// MARK: - Hashable Conformance

extension HTTPHeader: Hashable { }

// MARK: - Pattern Matching

extension HTTPHeader {
    public static func ~= (pattern: HTTPHeader, value: HTTPHeader) -> Bool {
        return pattern == value
    }

    public var explode: (name: Name, value: String) {
        return (self.name, self.value)
    }
}

// MARK: - Predefined Headers

public extension HTTPHeader.Name {

    static let contentType: HTTPHeader.Name = "Content-Type"
}

public extension HTTPHeader {

    static let contentType: (String) -> HTTPHeader = { value in
        return HTTPHeader(name: .contentType, value: value)
    }
}
