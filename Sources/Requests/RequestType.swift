//
// Created by Alex Jackson on 01/09/2018.
//

import Foundation

public protocol RequestType {

    var scheme: String? { get set }

    var host: String? { get set }

    var path: String { get set }

    var method: HTTPMethod { get set }

    func forFoundation() -> Foundation.URLRequest
}

extension RequestType {

    public func using(scheme: String) -> Self {
        var copy = self
        copy.scheme = scheme
        return copy
    }

    public func to(host: String) -> Self {
        var copy = self
        copy.host = host
        return copy
    }

    public func `for`(endpoint: String) -> Self {
        var copy = self
        copy.path = endpoint
        return copy
    }

    public func using(method: HTTPMethod) -> Self {
        var copy = self
        copy.method = method
        return copy
    }

}
