//
//  Created by Alex Jackson on 16/09/2017.
//  Copyright © 2017 Alex Jackson. All rights reserved.
//

import Foundation

/// A type that can convert itself into a Foundation `URLRequest`.
///
/// ## Overview
///
/// Conforming types provide all the information needed to create a `URLRequest` for a `Resource` from an API. The
/// associated `Resource` type is the type encoded in the body of the response to the request. Conforming types provide
/// a `ResponseDecoder<Resource>` that is responsible for transforming the raw response data into the associated
/// `Resource` for the request.
///
/// ## Conforming to the `RequestConvertible` Protocol
///
/// Conforming to the `RequestConvertible` protocol requires you specify an associated `Resource` type and declare:
///
/// - The base URL for the request.
/// - The endpoint for the request.
/// - The HTTP method for the request.
/// - The decoder for the associated resource type.
///
/// Default implementations of other properties are provided using the values defined in `DefaultValue`. Where it can be
/// inferred from the `Resource` type, a default `ResponseDecoder` is also provided.
///
/// - Note: If your request does not expect a response body, set the associated `Resource` type to `Void`.
///
public protocol RequestConvertible: CustomStringConvertible {

    /// The type encoded in the body of the response for `Request`.
    associatedtype Resource

    /// The base URL of the API. Convention dictates that this **should not** end with a trailing slash.
    var baseURL: URL { get }

    /// The path to the endpoint of the API. Convention dictates that this **should** start with a forwards slash.
    var endpoint: String { get }

    /// The HTTP method to use with the request.
    var method: HTTPMethod { get }

    /// HTTP header to be submitted in the request. Defaults to an empty header.
    var header: Header { get }

    /// URL query parameters to be submitted in the request. Defaults to an empty array.
    ///
    /// - Note: An empty array of query items is interpreted as no query items. The resulting URL will have no query
    /// query parameter component.
    ///
    var queryItems: [URLQueryItem] { get }

    /// The caching policy to specify when converted to a `URLRequest`. Defaults to `.useProtocolCachePolicy`.
    var cachePolicy: URLRequest.CachePolicy { get }

    /// The timeout interval to specify when converted to a `URLRequest`. Defaults to `60.0`.
    var timeoutInterval: TimeInterval { get }

    /// The data sent in the body of the request or `nil` if no data should be sent. Defaults to `nil`.
    var httpBody: Data? { get }

    var responseDecoder: ResponseDecoder<Resource> { get }
}

// MARK: - Default Implementations

extension RequestConvertible {

    public var header: Header {
        return DefaultValue.header
    }

    public var httpBody: Data? {
        return DefaultValue.httpBody
    }

    public var cachePolicy: URLRequest.CachePolicy {
        return DefaultValue.cachePolicy
    }

    public var timeoutInterval: TimeInterval {
        return DefaultValue.timeout
    }

    public var queryItems: [URLQueryItem] {
        return DefaultValue.queryItems
    }
}

// MARK: Void Response

extension RequestConvertible where Resource == Void {
    public var responseDecoder: ResponseDecoder<Resource> {
        return .none
    }
}

// MARK: String Response

extension RequestConvertible where Resource == String {
    public var responseDecoder: ResponseDecoder<String> {
        return .text
    }
}

// MARK: Data Response

extension RequestConvertible where Resource == Data {
    public var responseDecoder: ResponseDecoder<Data> {
        return .data
    }
}

// MARK: - Request Conversion

extension RequestConvertible {

    /// Converts the `RequestConvertible` into a Foundation `URLRequest`.
    ///
    /// - Returns: A `URLRequest` constructed from the instance.
    ///
    /// - Throws: A `RequestError.invalidRequest` if a valid `URLRequest` could not be constructed.
    ///
    public func toURLRequest() throws -> URLRequest {
        let url = try buildRequestURL()

        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        request.httpBody = httpBody
        request.allHTTPHeaderFields = header.dictionaryValue
        return request
    }

    /// Constructs a `URL` from the request.
    ///
    /// - Throws: A `RequestError.invalidRequest` if a valid `URLRequest` could not be constructed.
    ///
    private func buildRequestURL() throws -> URL {
        let endpointURL = endpoint.isEmpty ? baseURL : baseURL.appendingPathComponent(endpoint)

        var endpointComponents = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false)
        endpointComponents?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = endpointComponents?.url else { throw RequestError.invalidRequest }
        return url
    }
}

// MARK: - CustomStringConvertible Implementation

extension RequestConvertible {
    public var description: String {
        if let url = (try?  toURLRequest())?.url {
            return "Request<\(Resource.self)> [\(method.rawValue)] (\(url))"
        } else {
            return "Request (INVALID)"
        }
    }
}
