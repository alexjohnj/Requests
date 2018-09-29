//
//  Request.swift
//  Placeholder
//
//  Created by Alex Jackson on 16/09/2017.
//  Copyright © 2017 Alex Jackson. All rights reserved.
//

import Foundation

public enum RequestError: Error {
    case invalidRequestURL
}

/// A Request encapsulates a network request. A `Request` knows how to transform itself into a URLRequest.
public protocol Request: CustomStringConvertible {

    /// The type of Response expected for `Request`
    associatedtype Response

    /// The base URL of the API
    var baseURL: URL { get }

    /// The path to the endpoint of the API.
    var endpoint: String { get }

    /// The HTTP method to use with the request
    var method: HTTPMethod { get }

    /// HTTP header to be submitted in the request.
    var header: Header { get }

    /// URL query parameters to be submitted in the request. Query parameters common to a certain API should be
    /// provided by this property and implemented in a protocol extension.
    var queryParameters: [String: String]? { get }

    /// The caching policy to specify when converted to a `URLRequest`. Defaults to `.useProtocolCachePolicy`.
    var cachePolicy: URLRequest.CachePolicy { get }

    /// The timeout interval to specify when converted to a `URLRequest`. Defaults to `60.0`.
    var timeoutInterval: TimeInterval { get }

    /// The data sent in the body of the request or `nil` if no data should be sent.
    var httpBody: Data? { get }
}

extension Request {
    internal var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }

    internal var timeoutInterval: TimeInterval {
        return 60.0
    }
}

extension Request {
    /**
     Transform a `Request` into a Foundation `URLRequest`.

     - returns: A `URLRequest` or `nil` if a valid URL can not be constructed.
     */
    public func toURLRequest() throws -> URLRequest {
        let url = try buildRequestURL()

        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        request.httpBody = httpBody
        request.allHTTPHeaderFields = header.dictionaryValue
        return request
    }

    /**
     Construct a URL from a `Request`.

     - returns: A valid `URL` or `nil` if one can't be constructed.
     */
    private func buildRequestURL() throws -> URL {
        let endpointURL = baseURL.appendingPathComponent(endpoint)
        var endpointComponents = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false)

        let queryItems = queryParameters?.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }

        endpointComponents?.queryItems = queryItems

        guard let url = endpointComponents?.url else { throw RequestError.invalidRequestURL }
        return url
    }
}

// MARK: - CustomStringConvertible Implementation

extension Request {
    public var description: String {
        if let url = (try?  toURLRequest())?.url {
            return "Request<\(Response.self)> [\(method.rawValue)] (\(url))"
        } else {
            return "Request (INVALID)"
        }
    }
}
