//
// Created by Alex Jackson on 2018-11-27.
//

import Foundation

/// Default values for request parameters.
///
/// Default values are declared here so they are consistent between the `Request<Response>` type and the `RequestType`
/// protocol.
public enum DefaultValue {

    /// The `GET` method.
    public static let method: HTTPMethod = .get

    /// An empty `Header`.
    public static let header: Header = .empty

    /// An empty array of query items.
    public static let queryItems: [URLQueryItem] = []

    /// The `useProtocolCachePolicy`.
    public static let cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy

    /// 60 seconds.
    public static let timeout: TimeInterval = 60

    /// A `none` body provider.
    public static let bodyProvider: BodyProvider = .none
}
