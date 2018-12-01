//
//  ResponseDecoder.swift
//  Requests
//
//  Created by Alex Jackson on 24/11/2018.
//

import Foundation

/// A type that can decode a response type from the raw body of a HTTP response.
public struct ResponseDecoder<Response> {

    /// The body of the decoder.
    public let decode: (HTTPURLResponse, Data) throws -> Response

    public init(_ decode: @escaping (HTTPURLResponse, Data) throws -> Response) {
        self.decode = decode
    }
}

// MARK: - No Body Decoding

extension ResponseDecoder where Response == Void {

    /// A decoder that always returns a `()` value.
    public static let none = ResponseDecoder { _, _ in () }
}

// MARK: - Raw Data Decoding

extension ResponseDecoder where Response == Data {

    /// Returns the response data unchanged. Never throws an error.
    public static let data = ResponseDecoder { _, data in data }
}

// MARK: - String Decoding

extension ResponseDecoder where Response == String {

    /// Decodes a UTF8 string from the response data.
    public static let text = ResponseDecoder<String>.text(encoding: .utf8)

    /// Decodes a string from the response data.
    ///
    /// - parameter encoding: The encoding of the response data.
    ///
    /// - Throws: `CocoaError.fileReadInapplicableStringEncoding` if the encoding is incorrect.
    ///
    public static func text(encoding: String.Encoding) -> ResponseDecoder<String> {
        return ResponseDecoder { _, data in
            guard let string = String(data: data, encoding: encoding) else {
                throw CocoaError(.fileReadInapplicableStringEncoding,
                                 userInfo: [NSStringEncodingErrorKey: encoding.rawValue])
            }

            return string
        }
    }
}

extension ResponseDecoder {

    /// Decodes a JSON encoded object from some response data.
    ///
    /// - parameter resourceType: A `Decodable` resource type that the decoder should decode.
    /// - parameter decoder: The JSON decoder to decode the data with. Default `JSONDecoder()`.
    ///
    /// - Throws: Any error that can be thrown by a `JSONDecoder`.
    ///
    public static func json<T: Decodable>(encoded resourceType: T.Type, decoder: JSONDecoder = JSONDecoder())
        -> ResponseDecoder<T> {
        return ResponseDecoder<T>.json(decoder: decoder)
    }
}

// MARK: - Decodable Decoding

extension ResponseDecoder where Response: Decodable {

    /// Decodes a JSON encoded object from the response data.
    ///
    /// - parameter decoder: The json decoder to decode the data with. Default `JSONDecoder()`.
    ///
    /// - Throws: Any error that can be thrown by `JSONDecoder`.
    ///
    public static func json(decoder: JSONDecoder = JSONDecoder()) -> ResponseDecoder<Response> {
        return ResponseDecoder { _, data in return try decoder.decode(Response.self, from: data) }
    }
}
