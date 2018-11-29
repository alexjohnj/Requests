//
// Created by Alex Jackson on 2018-11-30.
//

import Foundation
import XCTest

import Requests

private struct TestError: Error { }

private extension URLResponse {

    static let success: (URLRequest) -> URLResponse = { request in
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }

}

private extension ResponseDecoder {

    /// A response decoder that always throws a `TestError`.
    static func throwingDecoder<T>(forType: T.Type) -> ResponseDecoder<T> {
        return ResponseDecoder<T> { _ in throw TestError() }
    }
}

final class URLSessionExtensionTests: XCTestCase {

    // MARK: - Properties

    private var session: URLSession!

    private let api = AnonymousRequestProvider("https://example.org")

    // MARK: - XCTestCase Overrides

    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.default
        config.protocolClasses = [HTTPStubProtocol.self]
        session = URLSession(configuration: config)
    }

    override func tearDown() {
        session = nil
        HTTPStubProtocol.removeAllStubs()

        super.tearDown()
    }

    // MARK: - Helpers

    private func stub<R: RequestConvertible>(_ request: R, with handler: @escaping (URLRequest) -> (Data?, URLResponse?, Error?)) throws {
        let urlRequest = try request.toURLRequest()
        let stub = HTTPStubProtocol.Stub(
          predicate: { $0 == urlRequest },
          handler: handler
        )

        HTTPStubProtocol.register(stub: stub)
    }

    // MARK: - Tests

    // MARK: Requests expecting responses without bodies

    private func assertCompletionHandlerInvokedOnCorrectQueue<R: RequestConvertible>(
      for request: R,
      file: StaticString = #file,
      line: UInt = #line
    ) {
        // Given
        let exp = expectation(description: "Waiting for URLSession completion block to be called")
        let callbackQueue = DispatchQueue(label: "org.alexj.RequestsTests.CompletionBlockQueue")
        let queueKey = DispatchSpecificKey<String>()
        let expectedQueueValue = "Callback queue"
        callbackQueue.setSpecific(key: queueKey, value: expectedQueueValue)
        var recordedQueueValue: String?

        // When
        session.perform(request, callbackQueue: callbackQueue) { _ in
            recordedQueueValue = DispatchQueue.getSpecific(key: queueKey)
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        XCTAssertEqual(recordedQueueValue, expectedQueueValue, file: file, line: line)
        callbackQueue.setSpecific(key: queueKey, value: nil)
    }

    func test_performRequest_invokesCompletionHandlerOnCallbackQueue_ForSuccessfulResponse() throws {
        // Given
        let request = api.get(.none, from: "/test")
        try stub(request) { r in return (nil, .success(r), nil) }

        // When, Then
        assertCompletionHandlerInvokedOnCorrectQueue(for: request)
    }

    func test_performRequest_invokesCompletionHandlerOnMainQueueByDefault() throws {
        // Given
        let exp = expectation(description: "Waiting for URLSession to invoke completion handler.")
        let request = api.get(.none, from: " /test")
        try stub(request) { r in return (nil, .success(r), nil) }
        var invokedOnMainThread = false

        // When
        session.perform(request) { _ in
            invokedOnMainThread = Thread.isMainThread
            exp.fulfill()
        }
        waitForExpectations(timeout: 1)

        // Then
        XCTAssertTrue(invokedOnMainThread, "Completion block was not run on the main queue")
    }

    func test_performRequest_invokesCompletionHandlerOnCallbackQueue_ForClientSideError() throws {
        // Given
        let request = api.get(.none, from: "/test")
        try stub(request) { _ in
            return (nil, nil, NSError(domain: URLError.errorDomain, code: URLError.dataNotAllowed.rawValue))
        }

        // When, Then
        assertCompletionHandlerInvokedOnCorrectQueue(for: request)
    }

    func test_performRequest_invokesCompletionHandlerOnCallbackQueue_ForDecodingError() throws {
        // Given
        let request = api.get(.throwingDecoder(forType: String.self), from: "/test")
        try stub(request) { r in
            return ("test".data(using: .utf8)!, URLResponse.success(r), nil)
        }

        // When, Then
        assertCompletionHandlerInvokedOnCorrectQueue(for: request)
    }

    func test_performRequest_invokesCompletionHandler_ForSuccessfulResponse() throws {
        // Given
        let exp = expectation(description: "Waiting for URLSession to invoke completion handler.")
        let request = api.get(.text, from: "/test")
        let expectedResource = "test"
        let expectedResponse = HTTPURLResponse.success(try! request.toURLRequest()) as! HTTPURLResponse
        var recordedResult: Result<String>?

        try stub(request) { r in
            return (expectedResource.data(using: .utf8)!, expectedResponse, nil)
        }

        // When
        session.perform(request) { result in
            recordedResult = result
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        guard case .success(let response, let resource)? = recordedResult else {
            XCTFail("Request result was \(String(describing: recordedResult)) when it should be success")
            return
        }

        XCTAssertEqual(resource, expectedResource)
        // URLResponse does not implement `isEqual(_:)` so we have to check the properties.
        XCTAssertEqual(response.statusCode, expectedResponse.statusCode)
        XCTAssertEqual(response.url, expectedResponse.url)
    }

    func test_performRequest_invokesCompletionHandler_ForClientSideError() throws {
        // Given
        let exp = expectation(description: "Waiting for URLSession to invoke completion handler.")
        let expectedError = NSError(domain: URLError.errorDomain, code: URLError.dataNotAllowed.rawValue)
        let request = api.get(.none, from: "/test")
        try stub(request) { r in
            return (nil, nil, expectedError)
        }
        var recordedResult: Result<Void>?

        // When
        session.perform(request) { result in
            recordedResult = result
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then

        guard case .failed(let maybeResponse, let error)? = recordedResult else {
            XCTFail("Request result was \(String(describing: recordedResult)) not failed")
            return
        }

        XCTAssertNil(maybeResponse)
        XCTAssertEqual(error as NSError, expectedError)
    }

    func test_performRequest_invokesCompletionHandler_ForDecodingErrorAfterGettingAResponse() throws {
        // Given
        let exp = expectation(description: "Waiting for URLSession to invoke completion handler.")
        let request = api.get(.throwingDecoder(forType: String.self), from: "/test")
        try stub(request) { r in
            return ("test".data(using: .utf8)!, .success(r), nil)
        }
        var recordedResult: Result<String>?

        // When
        session.perform(request) { result in
            recordedResult = result
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        guard case .failed(let maybeResponse, let error)? = recordedResult else {
            XCTFail("Request result was \(String(describing: recordedResult)) not failed")
            return
        }

        XCTAssertNotNil(maybeResponse)
        XCTAssert(error is TestError, "Got an \(error) not a \(TestError.self)")
    }

    func test_performRequest_invokesCompletionHandler_ForNonHTTPResponse() throws {
        // Given
        let exp = expectation(description: "Waiting for URLSession to invoke completion handler.")
        let request = api.get(.none, from: "/test")
        try stub(request) { r in
            // note, not a HTTPURLResponse
            return (nil, URLResponse(url: r.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil), nil)
        }
        var recordedResult: Result<Void>?

        // When
        session.perform(request) { result in
            recordedResult = result
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        guard case .failed(let maybeResponse, let error)? = recordedResult else {
            XCTFail("Request result was \(String(describing: recordedResult)) not failed(nil, error)")
            return
        }

        XCTAssertNil(maybeResponse)
        XCTAssert(
          {
              guard case RequestError.nonHttpResponse = error else {
                  return false
              }

              return true
          }(),
          "Got \(error) but expected \(RequestError.nonHttpResponse)"
        )
    }

    func test_performRequest_invokesCompletionHandler_ForNoResponseAndNoError() throws {
        // Given
        let exp = expectation(description: "Waiting for URLSession to invoke completion handler.")
        let request = api.get(.none, from: "/test")
        try stub(request) { r in
            return (nil, nil, nil)
        }
        var recordedResult: Result<Void>?

        // When
        session.perform(request) { result in
            recordedResult = result
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        guard case .failed(let maybeResponse, let error)? = recordedResult else {
            XCTFail("Request result was \(String(describing: recordedResult)) not failed(nil, error)")
            return
        }

        XCTAssertNil(maybeResponse)
        XCTAssert(
          {
              guard case RequestError.noResponse = error else {
                  return false
              }

              return true
          }(),
          "Got \(error) but expected \(RequestError.noResponse)"
        )

    }

    func test_performRequest_performsDecodingOnDecodingQueue() throws {
        // Given
        let exp = expectation(description: "Waiting for session completion block to be called.")
        let decodingQueue = DispatchQueue(label: "org.alexj.Requests.TestDecodingQueue")
        let queueKey = DispatchSpecificKey<String>()
        let expectedKeyValue = "decoding queue test"
        decodingQueue.setSpecific(key: queueKey, value: expectedKeyValue)
        defer { decodingQueue.setSpecific(key: queueKey, value: nil) }
        var recordedKeyValue: String?

        let decoder = ResponseDecoder<String> { _ in
            recordedKeyValue = DispatchQueue.getSpecific(key: queueKey)
            return "blah"
        }

        let request = api.get(decoder, from: "/test")
        try stub(request) { r in
            return (Data(bytes: [0, 1, 0, 1]), .success(r), nil)
        }

        // When
        session.perform(request, decodingQueue: decodingQueue) { _ in
            exp.fulfill()
        }

        waitForExpectations(timeout: 1)

        // Then
        XCTAssertEqual(recordedKeyValue, expectedKeyValue)
    }

    func test_performRequest_invokesConfigurationBlock() throws {
        // Given
        let exp = expectation(description: "Waiting for session to invoke completion block.")
        let request = api.get(.none, from: "/test")
        try stub(request) { r in return (nil, .success(r), nil) }
        var invokedConfigurationBlock = false

        // When
        session.perform(request, configureTask: { _ in invokedConfigurationBlock = true}) { _ in exp.fulfill() }
        waitForExpectations(timeout: 1)

        // Then
        XCTAssertTrue(invokedConfigurationBlock)
    }
}
