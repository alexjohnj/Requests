//
//  Created by Alex Jackson on 16/09/2017.
//  Copyright © 2017 Alex Jackson. All rights reserved.
//

import Foundation

// MARK: - API Host

/// A type that provides an interface to create requests to an API.
///
/// ## Overview
///
/// For each API, create a type that conforms to `RequestProviding` and implement the base URL of the API. Using this
/// type you can create `Request`s for the different endpoints of the API using the construction methods provided by the
/// protocol.
///
/// You can optionally implement the `request(to:using:)` method to customize the default request provided by the other
/// construction methods.
///
/// - SeeAlso: `AnonymousRequestProvider`
///
public protocol RequestProviding {

    /// The base url of all requests to the API. Convention dictates that this URL **should not** have a trailing slash.
    var baseURL: URL { get }

    /// Constructs a new request to an endpoint of the API using a specific HTTP method.
    ///
    /// - parameter endpoint: The endpoint for the request.
    /// - parameter method: The HTTP method for the request.
    ///
    /// - Returns: A new `Request` to the endpoint using the method.
    ///
    func request(to endpoint: String, using method: HTTPMethod) -> Request<Self, Void>
}

// MARK: - Request Creation

extension RequestProviding {

    public func request(to endpoint: String, using method: HTTPMethod) -> Request<Self, Void> {
        return Request(api: self, endpoint: endpoint, responseDecoder: .none, method: method)
    }

    /// Constructs a `GET` request for a resource at an endpoint of the API.
    ///
    /// - parameter resourceDecoder: A decoder for the resource at the endpoint.
    /// - parameter endpoint: The endpoint to retrieve the resource from.
    ///
    /// - Returns: A new request for the resource at the endpoint
    ///
    public func get<NewResource>(_ resourceDecoder: ResponseDecoder<NewResource>, from endpoint: String)
        -> Request<Self, NewResource> {
        return request(to: endpoint, using: .get).receiving(resourceDecoder)
    }

    /// Constructs a `POST` request sending a body of data to an endpoint of the API.
    ///
    /// - parameter body: The data to send in the request's body.
    /// - parameter endpoint: The endpoint to send the data to.
    ///
    /// - Returns: A new request to send the data to the endpoint.
    ///
    public func post(_ body: BodyProvider, to endpoint: String) -> Request<Self, Void> {
        return request(to: endpoint, using: .post).sending(body)
    }

    /// Constructs a `PUT` request sending a body of data to an endpoint of the API.
    ///
    /// - parameter body: The data to send in the request's body.
    /// - parameter endpoint: The endpoint to send the data to.
    ///
    /// - Returns: A new request to send the data to the endpoint.
    ///
    public func put(_ body: BodyProvider, to endpoint: String) -> Request<Self, Void> {
        return request(to: endpoint, using: .put).sending(body)
    }

    /// Constructs a `PATCH` request sending a body of data to an endpoint of the API.
    ///
    /// - parameter endpoint: The endpoint to send the data to.
    /// - parameter body: The data to send in the request's body.
    ///
    /// - Returns: A new request to send the data to the endpoint.
    ///
    public func patch(_ endpoint: String, with body: BodyProvider) -> Request<Self, Void> {
        return request(to: endpoint, using: .patch).sending(body)
    }

    /// Constructs a `DELETE` request for a resource at an endpoint of the API.
    ///
    /// - parameter endpoint: The endpoint of the resource to delete.
    ///
    /// - Returns: A new request to delete a resource.
    ///
    public func delete(_ endpoint: String) -> Request<Self, Void> {
        return request(to: endpoint, using: .delete)
    }

    /// Constructs a `HEAD` request for the headers of a resource at an endpoint of the API.
    ///
    /// - parameter endpoint: The endpoint of the resource to retrieve the headers of.
    ///
    /// - Returns: A new request to retrieve the headers of a resource.
    ///
    public func head(_ endpoint: String) -> Request<Self, Void> {
        return request(to: endpoint, using: .head)
    }
}

/// A `RequestProviding` type to a single API host.
///
/// Use an `AnonymousRequestProvider` for one-off API requests or when you do not care about the `API` parameter of the
/// `Request` type.
///
public struct AnonymousRequestProvider: RequestProviding {

    public let baseURL: URL

    /// Initialises a new request provider with the provided base URL.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }
}

extension AnonymousRequestProvider {

    /// Initialises a new request provider with the provided base URL string.
    ///
    /// - parameter baseURL: A string containing the base URL of the API.
    ///
    /// - Warning: `baseURL` must contain a valid URL.
    ///
    public init(_ baseURL: StaticString) {
        self.init(baseURL: URL(baseURL))
    }
}

/// A request for a resource from an API.
///
/// ## Overview
///
/// The `Request` structure is a concrete implementation of a `RequestConvertible` that provides a chainable
/// builder-like interface to constructing requests. You rarely instantiate a `Request` directly. Instead, requests to a
/// specific API are created by a `RequestProviding` type and are customised using the builder functions on `Request`.
///
/// The `Request` structure is generic over the `API` type and the `Resource` type. The `API` parameter is immutable and
/// can be used to constrain extensions on `Request` to a specific API. The `Resource` parameter is "mutable" in the
/// sense that it can be changed using the `receiving(_:)` builder function.
///
/// ## One-off Requests
///
/// A convenience initializer `init(method:baseURL:endpoint:)` is provided for one-off requests. This uses an
/// `AnonymousRequestProvider` and is intended to be used for exploratory work with an API. Its use outside of this
/// context is strongly discouraged.
///
/// - SeeAlso: `RequestConvertible`
/// - SeeAlso: `RequestProviding`
///
public struct Request<API: RequestProviding, Resource>: RequestConvertible {

    // MARK: - Public Properties

    public let api: API

    public var baseURL: URL {
        return api.baseURL
    }

    public var endpoint: String

    public var method: HTTPMethod

    public var header: Header

    public var queryItems: [URLQueryItem]

    public var cachePolicy: URLRequest.CachePolicy

    public var timeoutInterval: TimeInterval

    public var bodyProvider: BodyProvider

    public var responseDecoder: ResponseDecoder<Resource>

    public var authenticationProvider: AuthenticationProvider

    // MARK: - Initializers

    /// Initialises a new `Request` with the provided parameters. Default values for optional parameters are defined in
    /// the `DefaultValue` type.
    ///
    /// - SeeAlso: `DefaultValue`
    /// - SeeAlso: `RequestConvertible`
    ///
    public init(
      api: API,
      endpoint: String,
      responseDecoder: ResponseDecoder<Resource>,
      method: HTTPMethod = DefaultValue.method,
      header: Header = DefaultValue.header,
      queryItems: [URLQueryItem] = DefaultValue.queryItems,
      cachePolicy: URLRequest.CachePolicy = DefaultValue.cachePolicy,
      timeoutInterval: TimeInterval = DefaultValue.timeout,
      bodyProvider: BodyProvider = DefaultValue.bodyProvider,
      authenticationProvider: AuthenticationProvider = DefaultValue.authenticationProvider
    ) {
        self.api = api
        self.endpoint = endpoint
        self.method = method
        self.header = header
        self.queryItems = queryItems
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.bodyProvider = bodyProvider
        self.authenticationProvider = authenticationProvider

        self.responseDecoder = responseDecoder
    }
}

// MARK: - Convenience Initializers

extension Request where API == AnonymousRequestProvider, Resource == Void {

    /// Initialises a new request using an `AnonymousRequestProvider`.
    ///
    /// - Parameters:
    ///   - method: The HTTP method for the request.
    ///   - baseURL: The base url of the request and the anonymous request provider.
    ///   - endpoint: The endpoint of the request. Default `""`.
    ///
    /// - Warning: Use of this initializer outside of playgrounds and exploratory work is strongly discouraged.
    ///
    public init(method: HTTPMethod, baseURL: URL, endpoint: String = "") {
        self.init(api: AnonymousRequestProvider(baseURL: baseURL), endpoint: endpoint, responseDecoder: .none,
                  method: method)
    }

}

// MARK: - Method Manipulation

extension Request {

    /// Changes the HTTP method used by a request.
    ///
    /// - parameter method: The new method to use for the request.
    ///
    public func using(method: HTTPMethod) -> Request<API, Resource> {
        return self.setting(\.method, to: method)
    }

}

// MARK: - Header Manipulation

extension Request {

    /// Sets the header of the request to a new value.
    ///
    /// - parameter newHeader: The header to set for the request.
    ///
    /// - SeeAlso: `adding(headerField:)` to preserve the current header.
    /// - SeeAlso: `setting(headerField:)` to preserve the current header.
    ///
    public func with(header newHeader: Header) -> Request<API, Resource> {
        return self.setting(\.header, to: newHeader)
    }

    /// Adds the provided field to the request's header.
    ///
    /// - parameter headerField: A field to add to the request.
    ///
    /// - SeeAlso: `setting(headerField:)` to replace an existing field.
    ///
    public func adding(headerField: Field) -> Request<API, Resource> {
        var copy = self
        copy.header.add(headerField)
        return copy
    }

    /// Adds the provided fields to the request's header.
    ///
    /// - parameter headerFields: The fields to add to the header of the request.
    ///
    public func adding(headerFields: [Field]) -> Request<API, Resource> {
        var copy = self
        headerFields.forEach { copy.header.add($0) }
        return copy
    }

    public func adding(headerFields: Field...) -> Request<API, Resource> {
        return self.adding(headerFields: Array(headerFields))
    }

    /// Sets the provided field in the request's header.
    ///
    /// - parameter headerField: A field to set in the request.
    ///
    /// - SeeAlso: `adding(headerField:)` to merge an existing field.
    ///
    public func setting(headerField: Field) -> Request<API, Resource> {
        var copy = self
        copy.header.set(headerField)
        return copy
    }
}

// MARK: - Query Manipulation

extension Request {

    /// Sets the query for the request to a new value.
    ///
    /// - parameter newQuery: Collection of query items to build the new query from.
    ///
    /// - SeeAlso: `adding(queryItem:)` to update an existing query.
    ///
    public func with(query newQuery: [URLQueryItem]) -> Request<API, Resource> {
        return self.setting(\.queryItems, to: newQuery)
    }

    /// Appends a new item to the query for the request.
    ///
    /// - parameter queryItem: The item to append.
    ///
    /// - SeeAlso: `with(query:)` to replace an existing query.
    ///
    public func adding(queryItem: URLQueryItem) -> Request<API, Resource> {
        var copy = self
        copy.queryItems.append(queryItem)
        return copy
    }

    /// Appends a collection of new query items to the request.
    ///
    /// - parameter queryItems: The items to append.
    ///
    /// - SeeAlso: `with(query:)` to replace an existing query.
    ///
    public func adding(queryItems newItems: [URLQueryItem]) -> Request<API, Resource> {
        var copy = self
        copy.queryItems.append(contentsOf: newItems)
        return copy
    }

    /// Appends a collection of new query items to the request.
    ///
    /// - parameter queryItems: The items to append.
    ///
    /// - SeeAlso: `with(query:)` to replace an existing query.
    ///
    public func adding(queryItems: URLQueryItem...) -> Request<API, Resource> {
        return self.adding(queryItems: Array(queryItems))
    }
}

// MARK: - Body Manipulation

extension Request {

    /// Sets the body provider of the request to `body`.
    public func sending(_ body: BodyProvider) -> Request<API, Resource> {
        return self.setting(\.bodyProvider, to: body)
    }

}

// MARK: - Response Manipulation

extension Request {

    /// Sets the response decoder of the request.
    ///
    /// - parameter resourceDecoder: A decoder for the new request's resource.
    ///
    public func receiving<NewResource>(_ resourceDecoder: ResponseDecoder<NewResource>) -> Request<API, NewResource> {
        return self.adapted(for: resourceDecoder)
    }

}

// MARK: Request Configuration Manipulation

extension Request {

    /// Sets the authentication provider for the request.
    ///
    /// - parameter authenticator: An authentication provider for the request.
    ///
    public func authenticated(with authenticator: AuthenticationProvider) -> Request<API, Resource> {
        return self.setting(\.authenticationProvider, to: authenticator)
    }

    /// Sets the timeout interval for the request.
    ///
    /// - parameter interval: The new timeout interval for the request in seconds.
    ///
    public func timeout(after interval: TimeInterval) -> Request<API, Resource> {
        return self.setting(\.timeoutInterval, to: interval)
    }

}

// MARK: - Private Helpers

extension Request {

    private func setting<T>(_ prop: WritableKeyPath<Request<API, Resource>, T>, to newValue: T) -> Request<API, Resource> {
        var copy = self
        copy[keyPath: prop] = newValue
        return copy
    }

    private func adapted<NewResource>(for newDecoder: ResponseDecoder<NewResource>) -> Request<API, NewResource> {
        return Request<API, NewResource>(
          api: api,
          endpoint: endpoint,
          responseDecoder: newDecoder,
          method: method,
          header: header,
          queryItems: queryItems,
          cachePolicy: cachePolicy,
          timeoutInterval: timeoutInterval,
          bodyProvider: bodyProvider
        )
    }
}
