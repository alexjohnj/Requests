//
//  RequestError.swift
//  Requests
//
//  Created by Alex Jackson on 24/11/2018.
//

import Foundation

/// Indicates a valid URL could not be constructed from a `RequestConvertible` type.
public struct InvalidRequestURLError: Error { }

/// An error that can occur when performing a request.
public enum RequestError: Error {

    /// The server did not respond.
    case noResponse

    /// The server replied with a non HTTP response.
    case nonHTTPResponse

    /// The server replied with an empty body when a request was expecting one.
    case noData

    /// The server's response did not pass the given response validation block.
    case unacceptableResponse
}

/// An error that wraps an error that occurred when executing a network request.
public struct RequestTransportError: Error {

    /// The error that caused the request to fail.
    public let underlyingError: Error

    /// The failed request or `nil` if the request could not be constructed.
    public let request: URLRequest?

    /// A response received before the error occurred or `nil` if there was no response.
    public let response: URLResponse?

    /// A HTTP response received before the error occurred or `nil` if there was no response or `response` is not an
    /// HTTP response.
    ///
    public var httpResponse: HTTPURLResponse? {
        return response as? HTTPURLResponse
    }

    public init(underlyingError: Error, request: URLRequest?, response: URLResponse?) {
        self.underlyingError = underlyingError
        self.request = request
        self.response = response
    }
}
