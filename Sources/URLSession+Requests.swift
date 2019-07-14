//
//  URLSession+Requests.swift
//  Requests
//
//  Created by Alex Jackson on 24/11/2018.
//

import Foundation

public typealias NetworkResult<Resource> = Result<(HTTPURLResponse, Resource), RequestTransportError>

extension URLSession {

    /// Executes a `RequestConvertible` request and attempts to decode the response body.
    ///
    /// - Parameters:
    ///   - request: A HTTP request to execute.
    ///   - decodingQueue: A `DispatchQueue` to decode the response body on. Default `.global(.userInitiated)`.
    ///   - callbackQueue: A `DispatchQueue` to run `completionHandler` on. Default `.main`.
    ///   - configureTask: A block that receives the `URLSessionTask` for the request. This block will only be called
    ///     if the `RequestType` is successfully converted to a `URLRequest`. You do not need to call `resume()` on the
    ///     provided task. The default implementation does nothing.
    ///   - completionHandler: A block executed when the request completes and the response body has been decoded.
    ///
    public func perform<R: RequestConvertible>(
      _ request: R,
      decodingQueue: DispatchQueue = .global(qos: .userInitiated),
      callbackQueue: DispatchQueue = .main,
      configureTask: (URLSessionTask) -> Void = { _ in },
      completionHandler: @escaping (NetworkResult<R.Resource>) -> Void
    ) {
        let complete = { (response: NetworkResult<R.Resource>) in
            callbackQueue.async { completionHandler(response) }
        }

        do {
            let urlRequest = try request.toURLRequest()
            let task = try dataTask(with: urlRequest, configurationBlock: configureTask) { data, response, error in

                // First check to see if there's a response and if there isn't, see if there's an error. There should be
                // but since there's no type guarantees, fall back to a `noResponse` error if there isn't.
                guard let response = response else {
                    if let error = error {
                        let transportError = RequestTransportError(underlyingError: error, request: urlRequest,
                                                                   response: nil)
                        complete(.failure(transportError))
                        return
                    } else {
                        let transportError = RequestTransportError(underlyingError: RequestError.noResponse,
                                                                   request: urlRequest, response: nil)
                        complete(.failure(transportError))
                        return
                    }
                }

                // Now try and get a HTTP response out of the original response.
                guard let httpResponse = response as? HTTPURLResponse else {
                    let transportError = RequestTransportError(underlyingError: RequestError.nonHTTPResponse,
                                                               request: urlRequest, response: response)
                    complete(.failure(transportError))
                    return
                }

                // Now make sure there were no client-side errors after the initial response. From my time playing with
                // `URLProtocol`, this doesn't seem possible as when the protocol sends an error to the client, the
                // response is set to `nil`. Nonetheless, there's no type-level guarantee so we must handle this state.
                guard error == nil else {
                    // swiftlint:disable:next force_unwrapping
                    let transportError = RequestTransportError(underlyingError: error!, request: urlRequest,
                                                               response: response)
                    complete(.failure(transportError))
                    return
                }

                // It's now safe to try and decode the resource from the response body.
                decodingQueue.async {
                    do {
                        let resource = try decodeBody(from: data, forResponse: httpResponse,
                                                      using: request.responseDecoder)
                        complete(.success((httpResponse, resource)))
                    } catch let decodingError {
                        let transportError = RequestTransportError(underlyingError: decodingError, request: urlRequest,
                                                                   response: response)
                        complete(.failure(transportError))
                    }
                }
            }

            task.resume()
        } catch {
            complete(.failure(RequestTransportError(underlyingError: error, request: nil, response: nil)))
        }
    }

    private func dataTask(
      with urlRequest: URLRequest,
      configurationBlock configureTask: (URLSessionTask) -> Void,
      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) throws -> URLSessionDataTask {
        let task = dataTask(with: urlRequest, completionHandler: completionHandler)
        configureTask(task)
        return task
    }
}

// MARK: - Helper Functions

private func decodeBody<Body>(from data: Data?, forResponse response: HTTPURLResponse,
                              using responseDecoder: ResponseDecoder<Body>) throws -> Body {
    guard Body.self != Void.self else { return () as! Body } // swiftlint:disable:this force_cast
    guard let data = data else { throw RequestError.noData }
    return try responseDecoder.decode(response, data)
}
