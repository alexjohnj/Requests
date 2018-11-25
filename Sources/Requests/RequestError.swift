//
//  RequestError.swift
//  Requests
//
//  Created by Alex Jackson on 24/11/2018.
//

import Foundation

public enum RequestError: Error {

    /// Indicates a `Request` could not be converted to a Foundation `URLRequest`.
    case invalidRequest

    /// The server did not give a response.
    case noResponse

    /// A server replied with a non HTTP response (wrapped).
    case nonHttpResponse(URLResponse)

    /// A server replied with an empty body when a request was expecting one.
    case noData
}
