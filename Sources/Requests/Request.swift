//
// Created by Alex Jackson on 01/09/2018.
//

import Foundation

public typealias BaseRequest = Request<Void>

public struct Request<Response> {

    private var urlComponents: URLComponents

    public var method: HTTPMethod = .get

    public func `for`<Resource>(resource: Resource.Type) -> Request<Resource> {
        return Request<Resource>(urlComponents: urlComponents, method: method)
    }
}

extension Request {
    public init(url: URL) {
        self.init(urlComponents: URLComponents(url: url, resolvingAgainstBaseURL: false)!, method: .get)
    }

    public init?(to urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.init(url: url)
    }
}

extension Request: RequestType {

    public var scheme: String? {
        get {
            return urlComponents.scheme
        }
        set {
            urlComponents.scheme = newValue
        }
    }

    public var host: String? {
        get {
            return urlComponents.host
        }
        set {
            urlComponents.host = newValue
        }
    }

    public var path: String {
        get {
            return urlComponents.path
        }

        set {
            urlComponents.path = newValue
        }
    }

    public func forFoundation() -> URLRequest {
        fatalError("forFoundation() has not been implemented")
    }
}
