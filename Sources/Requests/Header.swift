//
// Created by Alex Jackson on 29/09/2018.
//

import Foundation

/// A header in a HTTP request. A header consists of a series of fields containing a key and a value. Keys are
/// represented by the `Field.Name` type while values are simply `String`s.
///
/// - Note: A `Header` instance does not preserve the order of fields added to it.
///
public struct Header: Hashable {

    // MARK: - Public Properties

    /// A dictionary representation of the header.
    public var dictionaryValue: [String: String] {
        return storage.reduce(into: [:]) { accum, element in
            accum[String(describing: element.key.rawValue)] = element.value
        }
    }

    /// `true` if the header is empty.
    public var isEmpty: Bool { return storage.isEmpty }

    // MARK: - Private Properties

    private var storage: [Field.Name: String]

    // MARK: - Initializers

    /// Initializes a new `Header` containing the provided fields.
    ///
    /// - parameter fields: The fields to initialize the header with.
    ///
    public init(_ fields: [Field]) {
        let keysAndValues = fields.map(explode)

        self.storage = Dictionary(keysAndValues, uniquingKeysWith: { "\($0),\($1)" })
    }

    /// An empty header.
    public static var empty: Header {
        return Header([])
    }

    // MARK: - Public Methods

    /// Adds `field` into the header. If a field with the same name already exists, its value is joined with `field`'s
    /// value using a `,`.
    public mutating func add(_ field: Field) {
        if let existingValue = storage[field.name] {
            storage[field.name] = "\(existingValue),\(field.value)"
        } else {
            storage[field.name] = field.value
        }
    }

    /// Sets `field` in the header, replacing any existing values.
    public mutating func set(_ field: Field) {
        storage[field.name] = field.value
    }

    /// Removes the field named `name` from the header, returning the field if it was present.
    @discardableResult
    public mutating func remove(_ name: Field.Name) -> Field? {
        return storage.removeValue(forKey: name).map { Field(name: name, value: $0) }
    }

    /// Returns `true` if the header contains a value for the field named `field`.
    public func contains(_ name: Field.Name) -> Bool {
        return self[name] != nil
    }

    // MARK: - Public Subscripts

    /// Returns the value of the field named `name` in the header or `nil` if that field is not present in the header.
    public subscript(_ name: Field.Name) -> String? {
        return storage[name]
    }
}

// MARK: - Convenience Initializers

extension Header {
    public init(_ fields: Field...) {
        self.init(fields)
    }
}

// MARK: - Custom String Convertible Conformance

extension Header: CustomStringConvertible {

    public var description: String {
        return storage
          .lazy
          .map(Field.init)
          .map { $0.description }
          .joined(separator: "\n")
    }

}

// MARK: - Array Literal Conformance

extension Header: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Field...) {
        self.init(elements)
    }
}
