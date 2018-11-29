//
//  URLSession+Requests.swift
//  Requests
//
//  Created by Alex Jackson on 24/11/2018.
//

import Foundation

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
    /// - Remark: Wouldn't it be wonderful if Swift had a common `Result<T>` type?
    ///
    public func perform<R: RequestConvertible>(
      _ request: R,
      decodingQueue: DispatchQueue = .global(qos: .userInitiated),
      callbackQueue: DispatchQueue = .main,
      configureTask: (URLSessionTask) -> Void = { _ in },
      completionHandler: @escaping (Result<R.Resource>) -> Void
    ) {
        let complete = { (response: Result<R.Resource>) in
            callbackQueue.async { completionHandler(response) }
        }

        do {
            let task = try dataTask(with: request, configurationBlock: configureTask) { data, response, error in

                // First check to see if there's a response and if there isn't, see if there's an error. There should be
                // but since there's no type guarantees, fall back to a `noResponse` error if there isn't.
                guard let response = response else {
                    if let error = error {
                        complete(.failed(nil, error))
                        return
                    } else {
                        complete(.failed(nil, RequestError.noResponse))
                        return
                    }
                }

                // Now try and get a HTTP response out of the original response.
                guard let httpResponse = response as? HTTPURLResponse else {
                    complete(.failed(nil, RequestError.nonHttpResponse(response)))
                    return
                }

                // Now make sure there were no client-side errors after the initial response. From my time playing with
                // `URLProtocol`, this doesn't seem possible as when the protocol sends an error to the client, the
                // response is set to `nil`. Nonetheless, there's no type-level guarantee so we must handle this state.
                guard error == nil else {
                    // swiftlint:disable:next force_unwrapping
                    complete(.failed(httpResponse, error!))
                    return
                }

                // It's now safe to try and decode the resource from the response body.
                decodingQueue.async {
                    do {
                        let resource = try decodeResponse(from: data, using: request.responseDecoder)
                        complete(.success(httpResponse, resource))
                    } catch let decodingError {
                        complete(.failed(httpResponse, decodingError))
                    }
                }
            }

            task.resume()
        } catch {
            complete(.failed(nil, error))
        }
    }

    private func dataTask<R: RequestConvertible>(
      with request: R,
      configurationBlock configureTask: (URLSessionTask) -> Void,
      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) throws -> URLSessionDataTask {
        let urlRequest = try request.toURLRequest()
        let task = dataTask(with: urlRequest, completionHandler: completionHandler)
        configureTask(task)
        return task
    }
}

// MARK: - Helper Functions

private func decodeResponse<Response>(from data: Data?, using responseDecoder: ResponseDecoder<Response>) throws -> Response {
    guard Response.self != Void.self else { return () as! Response } // swiftlint:disable:this force_cast
    guard let data = data else { throw RequestError.noData }
    return try responseDecoder.decode(data)
}
