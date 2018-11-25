//
//  ResponseDecoder.swift
//  Requests
//
//  Created by Alex Jackson on 24/11/2018.
//

import Foundation

public struct ResponseDecoder<Response> {

    public let decode: (Data) throws -> Response

    public init(_ decode: @escaping (Data) throws -> Response) {
        self.decode = decode
    }
}

// MARK: - No Body Decoding

extension ResponseDecoder where Response == Void {

    public static let none = ResponseDecoder { _ in () }
}

// MARK: - Raw Data Decoding

extension ResponseDecoder where Response == Data {

    /// Returns the response data unchanged. Never throws an error.
    public static let data = ResponseDecoder { $0 }
}

// MARK: - String Decoding

extension ResponseDecoder where Response == String {

    /// Decodes a UTF8 string from the response data.
    public static let string = ResponseDecoder<String>.string(encoding: .utf8)

    /// Decodes a string from the response data.
    ///
    /// - parameter encoding: The encoding of the response data.
    ///
    /// - Throws: `CocoaError.fileReadInapplicableStringEncoding` if the encoding is incorrect.
    ///
    public static func string(encoding: String.Encoding) -> ResponseDecoder<String> {
        return ResponseDecoder { data in
            guard let string = String(data: data, encoding: encoding) else {
                throw CocoaError(.fileReadInapplicableStringEncoding,
                                 userInfo: [NSStringEncodingErrorKey: encoding.rawValue])
            }

            return string
        }
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
        return ResponseDecoder { return try decoder.decode(Response.self, from: $0) }
    }
}
