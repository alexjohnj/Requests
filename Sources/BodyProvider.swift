//
// Created by Alex Jackson on 2018-12-23.
//

import Foundation

/// A type that produces the body of a request and updates the header of a request accordingly.
///
/// A `BodyProvider` implements a function that takes an `inout` `Header` and produces a `RequestBody`. In the
/// `body(updating:)` method, the provider should construct the `RequestBody` and update the `Content-Type` of the
/// provided `Header`. The provider can also set any other relevant fields in the header.
///
/// Several predefined `BodyProvider`s are provided for text bodies and JSON bodies.
///
/// ## Creating a `BodyProvider`
///
/// The `body(updating:)` method is defined when the `BodyProvider` is initialised as a closure. The method is somewhat
/// odd because it doesn't take any data to convert to a `RequestBody` as input. In your `BodyProvider`s you should
/// capture the input data in the closure provided at initialization. This means that most `BodyProvider`s will be
/// provided by factory functions that take the input data and construct a new body provider using it.
///
/// When implementing a provider, ensure that updates to the provided `header` are only applied when any throwing
/// functions have succeeded. Otherwise you may end up in the situation where the header of a request is updated but its
/// body has not been created because an error was thrown during creation.
///
public struct BodyProvider {

    private let _body: (inout Header) throws -> RequestBody

    public init(encode: @escaping (inout Header) throws -> RequestBody) {
        self._body = encode
    }

    public func body(updating header: inout Header) throws -> RequestBody {
        return try _body(&header)
    }
}

public extension BodyProvider {

    /// An empty `BodyProvider`. This provider never throws an error, removes the `Content-Type` field of the header and
    /// always produces a `RequestBody.none`.
    ///
    static let none = BodyProvider { header in
        header.remove(.contentType)
        return .none
    }

    /// A body provider that wraps some raw data.
    ///
    /// This provider never throws an error.
    ///
    /// - parameter data: The data to set as the body.
    /// - parameter contentType: The `Content-Type` of `data`. Defaults to `application/octet-stream`.
    ///
    static func raw(data: Data, contentType: MediaType = .binary) -> BodyProvider {
        return BodyProvider { header in
            header.set(.contentType(contentType))
            return .data(data)
        }
    }

    /// A body provider that wraps a raw input stream.
    ///
    /// This provider never throws an error.
    ///
    /// - parameter stream: The stream to set as the body.
    /// - parameter contentType: The `Content-Type` of `stream`. Defaults to `application/octet-stream`.
    ///
    static func raw(stream: InputStream, contentType: MediaType = .binary) -> BodyProvider {
        return BodyProvider { header in
            header.set(.contentType(contentType))
            return .stream(stream)
        }
    }

    /// A body provider that produces a UTF-8 encoded body.
    ///
    /// - parameter text: The text to set as the body of the request.
    ///
    /// - Throws: A TextBodyEncodingError if `text` is not valid UTF-8 text.
    ///
    static func text(_ text: String) -> BodyProvider {
        return BodyProvider { header in
            guard let data = text.data(using: .utf8) else {
                throw TextBodyEncodingError.utf8EncodingFailed
            }

            header.set(.contentType(.plainText))
            return .data(data)
        }
    }

    /// A body provider that produces a JSON body representation of a value.
    ///
    /// - parameter value: The value to encode as the request's body.
    /// - parameter encoder: The encoder to encode `value` with. Defaults to `JSONEncoder()`.
    ///
    /// - Throws: Any error that can be thrown by `JSONEncoder`.
    ///
    static func json<T: Encodable>(encoded value: T, using encoder: JSONEncoder = JSONEncoder()) -> BodyProvider {
        return BodyProvider { header in
            let data = try encoder.encode(value)
            header.set(.contentType(.json))
            return .data(data)
        }
    }
}

// MARK: - Error Types

/// An error thrown when encoding a text request body.
public enum TextBodyEncodingError: Error {
    /// The text could not be encoded as utf8 text.
    case utf8EncodingFailed
}
