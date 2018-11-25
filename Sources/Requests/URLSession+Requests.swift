//
//  URLSession+Requests.swift
//  Requests
//
//  Created by Alex Jackson on 24/11/2018.
//

import Foundation

extension URLSession {

    /// Executes a `Request` that has no response body.
    ///
    /// - Parameters:
    ///   - request: A HTTP request to execute.
    ///   - callbackQueue: A `DispatchQueue` to run `completionHandler` on. Default `.main`.
    ///   - completionHandler: A block executed when the request completes.
    ///
    public func perform<R: Request>(
      _ request: R,
      callbackQueue: DispatchQueue = .main,
      completionHandler: @escaping (Result<Void>) -> Void
    ) where R.Resource == Void {

        // Runs `completionHandler` on `callbackQueue`.
        let complete = { (response: Result<Void>) in
            callbackQueue.async { completionHandler(response) }
        }

        do {
            let task = try dataTask(with: request) { _, response, error in
                do {
                    try ensureNoError(error)
                    let httpResponse = try extractRequiredHttpResponse(from: response)
                    complete(.success(httpResponse, ()))
                } catch {
                    complete(.failed(nil, error))
                }
            }

            task.resume()
        } catch {
            complete(.failed(nil, error))
        }
    }

    /// Executes a `Request` and attempts to decode the response body.
    ///
    /// - Parameters:
    ///   - request: A HTTP request to execute.
    ///   - decodingQueue: A `DispatchQueue` to decode the response body on. Default `.global(.userInitiated)`.
    ///   - callbackQueue: A `DispatchQueue` to run `completionHandler` on. Default `.main`.
    ///   - completionHandler: A block executed when the request completes and the response body has been decoded.
    ///
    /// - Note: Either the response or the error passed to the completion handler will have a value. They will never
    ///   both be `.none` or `.some`.
    ///
    /// - Remark: Wouldn't it be wonderful if Swift had a common `Result<T>` type?
    ///
    public func perform<R: Request>(
      _ request: R,
      decodingQueue: DispatchQueue = .global(qos: .userInitiated),
      callbackQueue: DispatchQueue = .main,
      completionHandler: @escaping (Result<R.Resource>) -> Void
    ) {
        let complete = { (response: Result<R.Resource>) in
            callbackQueue.async { completionHandler(response) }
        }

        do {
            let task = try dataTask(with: request) { maybeData, response, requestError in
                // The http response extracted from `response`. Placing the response at this scope means its accessible
                // by the `catch` block if `maybeData` is `nil`.
                var extractedResponse: HTTPURLResponse?

                do {
                    try ensureNoError(requestError)
                    let httpResponse = try extractRequiredHttpResponse(from: response)
                    extractedResponse = httpResponse
                    let data = try extractData(from: maybeData)

                    decodingQueue.async {
                        do {
                            let resource = try request.responseDecoder.decode(data)
                            complete(.success(httpResponse, resource))
                        } catch {
                            complete(.failed(httpResponse, error))
                        }
                    }

                } catch {
                    complete(.failed(extractedResponse, error))
                }
            }

            task.resume()
        } catch {
            complete(.failed(nil, error))
        }
    }

    private func dataTask<R: Request>(
      with request: R,
      completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) throws -> URLSessionDataTask {
        let urlRequest = try request.toURLRequest()
        return dataTask(with: urlRequest, completionHandler: completionHandler)
    }
}

// MARK: - Helper Functions

/// Throws the wrapped error if `error` is `nil`.
private func ensureNoError(_ error: Error?) throws {
    guard error == nil else {
        throw error!
    }
}

/// Extracts data wrapped by an optional, throwing a `RequestError.noData` error if there is no data.
private func extractData(from maybeData: Data?) throws -> Data {
    guard let data = maybeData else {
        throw RequestError.noData
    }

    return data
}

/// Extracts a `HTTPURLResponse` from an optional `URLResponse`.
///
/// - Throws: A `RequestError.noResponse` if `maybeResponse` is `nil`.
/// - Throws: A `RequestError.nonHttpResponse` if `maybeResponse` is not a HTTP response.
///
private func extractRequiredHttpResponse(from response: URLResponse?) throws -> HTTPURLResponse {
    guard let response = response else {
        throw RequestError.noResponse
    }

    guard let httpResponse = response as? HTTPURLResponse else {
        throw RequestError.nonHttpResponse(response)
    }

    return httpResponse
}
