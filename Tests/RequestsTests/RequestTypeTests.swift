//
//  RequestTests.swift
//  RequestsTests
//
//  Created by Alex Jackson on 23/09/2018.
//

import Foundation
import XCTest
import Requests

/// A request that has default values for all properties.
private protocol TestableRequest: RequestConvertible { }

extension TestableRequest {

    // The fix-it offered by xcode won't work as the compiler gets confused.
    typealias Resource = Void

    var baseURL: URL {
        return URL("https://example.com")
    }

    var endpoint: String {
        return "/test"
    }

    var method: HTTPMethod {
        return .get
    }

    /// The URL that wwould be produced by this request if none of its default properties are overridden.
    static var defaultTestUrl: URL {
        return URL("https://example.com/test")
    }
}

final class RequestTypeTests: XCTestCase {

    // MARK: - Test Cases

    func test_baseUrl_setCorrectly() throws {
        // Given
        struct SUT: TestableRequest {
            let baseURL = URL("https://example.com/api/")
            let endpoint = ""
        }
        let request = SUT()

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.url, request.baseURL)
    }

    // If the endpoint is empty, a trailing slash should not be appended to the base url.
    func test_endpoint_doesNotAppendSlashWhenEmpty() throws {
        // Given
        struct SUT: TestableRequest {
            let baseURL = URL("https://example.com/api")
            let endpoint = ""
        }
        let request = SUT()

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.url, request.baseURL)
    }

    func test_endpoint_appendedCorrectly() throws {
        // Given
        struct SUT: TestableRequest {
            let baseURL = URL("https://example.com/api")
            let endpoint = "/doSomething"
        }

        let request = SUT()
        let expectedUrl = URL("https://example.com/api/doSomething")

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.url, expectedUrl)
    }

    func test_queryItems_setCorrectly() throws {
        // Given
        struct SUT: TestableRequest {
            let queryItems: [URLQueryItem] = [
                "test": "value",
                "test2": "value2"
            ]
        }
        let request = SUT()
        let expectedUrl = URL(string: "\(SUT.defaultTestUrl)?test=value&test2=value2")!

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.url, expectedUrl)
    }

    func test_doesNot_appendEmptyQueryItems() throws {
        // Given
        struct SUT: TestableRequest {
            let queryItems: [URLQueryItem] = []
        }
        let request = SUT()

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.url, SUT.defaultTestUrl)
    }

    func test_headerSetCorrectly() throws {
        // Given
        struct SUT: TestableRequest {
            let header: Header = [
                Field.accept("application/json"),
                Field.contentType("text/html")
            ]
        }
        let request = SUT()

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNotNil(urlRequest.allHTTPHeaderFields)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, request.header.dictionaryValue)
    }

    func test_emptyHeader_producesEmptyNonNilHeader() throws {
        // Given
        struct SUT: TestableRequest {
            let header: Header = .empty
        }
        let request = SUT()

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNotNil(urlRequest.allHTTPHeaderFields)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, [:])
    }

    func test_httpMethod_setCorrectly() throws {
        // Given
        let expectedMethod = HTTPMethod.post
        struct SUT: TestableRequest {
            let method: HTTPMethod
        }
        let request = SUT(method: expectedMethod)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNotNil(urlRequest.httpMethod)
        XCTAssertEqual(urlRequest.httpMethod.map(HTTPMethod.init(rawValue:)), expectedMethod)
    }

    func test_httpBody_setCorrectly() throws {
        // Given
        let expectedBody = "Hello, world!".data(using: .utf8)!
        struct SUT: TestableRequest {
            let httpBody: Data?
        }
        let request = SUT(httpBody: expectedBody)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNotNil(urlRequest.httpBody)
        XCTAssertEqual(urlRequest.httpBody, expectedBody)
    }

    func test_emptyHttpBody_setCorrectly() throws {
        // Given
        struct SUT: TestableRequest {
            let body: Data?
        }
        let request = SUT(body: nil)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNil(urlRequest.httpBody)
    }

    func test_cachePolicy_setCorrectly() throws {
        // Given
        let expectedPolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        struct SUT: TestableRequest {
            let cachePolicy: URLRequest.CachePolicy
        }
        let request = SUT(cachePolicy: expectedPolicy)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.cachePolicy, expectedPolicy)
    }

    func test_timeoutInterval_setCorrectly() throws {
        // Given
        let expectedTimeout = 42 as TimeInterval
        struct SUT: TestableRequest {
            let timeoutInterval: TimeInterval
        }
        let request = SUT(timeoutInterval: expectedTimeout)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.timeoutInterval, expectedTimeout)
    }
}
