//
// Created by Alex Jackson on 2018-11-30.
//

import Foundation

internal final class HTTPStubProtocol: URLProtocol {

    struct Stub {
        let predicate: (URLRequest) -> Bool
        let handler: (URLRequest) -> (Data?, URLResponse?, Error?)
    }

    private static var stubs: [Stub] = []

    // MARK: - Public Methods

    public static func register(stub: Stub) {
        stubs.append(stub)
    }

    public static func removeAllStubs() {
        stubs.removeAll()
    }

    // MARK:  - URLProtocol Overrides

    override func startLoading() {
        let response: URLResponse?
        let data: Data?
        let error: Error?

        defer {
            if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }

            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            }

            client?.urlProtocolDidFinishLoading(self)
        }

        guard let stub = HTTPStubProtocol.stubs.first(where: { $0.predicate(request) }) else {
            response = nil
            data = nil
            error = NSError(domain: URLError.errorDomain, code: URLError.unsupportedURL.rawValue)
            return
        }

        (data, response, error) = stub.handler(request)
    }

    override func stopLoading() {
        // No op...
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = (task.currentRequest ?? task.originalRequest) else { return false }
        return stubs.contains { $0.predicate(request) }
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
}
