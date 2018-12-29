//
// Created by Alex Jackson on 22/09/2018.
//

/// A header field in a HTTP request. A field consists of a key-value pair mapping `name` onto `value`.
///
/// - Note: As HTTP headers are case insensitive, the implementations of `Hashable` and `Equatable` take this into
/// consideration and convert all header names to lowercase before comparing them.
///
public struct Field {

    // MARK: - Nested Types

    /// The name of a header field in a HTTP request.
    public struct Name: Hashable, RawRepresentable, ExpressibleByStringLiteral, CustomStringConvertible {

        // MARK: - Public Properties

        public let rawValue: CaseInsensitiveString

        public var description: String {
            return rawValue.description
        }

        // MARK: - Initializers

        public init(rawValue: CaseInsensitiveString) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.init(rawValue: CaseInsensitiveString(rawValue))
        }

        public init(stringLiteral value: String) {
            self.init(rawValue: CaseInsensitiveString(value))
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

extension Field: CustomStringConvertible {
    public var description: String {
        return "\(name): \(value)"
    }
}

// MARK: - Equatable Conformance

extension Field: Equatable { }

// MARK: - Hashable Conformance

extension Field: Hashable { }

// MARK: - Pattern Matching

extension Field {
    public static func ~= (pattern: Field, value: Field) -> Bool {
        return pattern == value
    }
}

// MARK: - Field Functions

public func explode(_ field: Field) -> (name: Field.Name, value: String) {
    return (field.name, field.value)
}

// MARK: - Predefined Headers

public extension Field.Name {

    static let accept: Field.Name = "Accept"

    static let acceptLanguage: Field.Name = "Accept-Language"

    static let authorization: Field.Name = "Authorization"

    static let contentType: Field.Name = "Content-Type"

}

public extension Field {

    static let contentType: (MediaType) -> Field = { Field(name: .contentType, value: $0.rawValue) }

    static let accept = { Field(name: .accept, value: $0) }

    static let acceptLanguage = { Field(name: .acceptLanguage, value: $0) }

}
