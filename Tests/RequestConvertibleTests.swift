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

    var baseURL: URL {
        return URL("https://example.com")
    }

    var endpoint: String {
        return "/test"
    }

    var method: HTTPMethod {
        return .get
    }

    /// The URL that would be produced by this request if none of its default properties are overridden.
    static var defaultTestUrl: URL {
        return URL("https://example.com/test")
    }
}

final class RequestConvertibleTests: XCTestCase {

    // MARK: - Base URL Tests

    func test_baseUrl_setCorrectly() throws {
        // Given
        struct SUT: TestableRequest {
            typealias Resource = String
            let baseURL = URL("https://example.com/api/")
            let endpoint = ""
        }
        let request = SUT()

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.url, request.baseURL)
    }

    // MARK: - Endpoint Tests

    // If the endpoint is empty, a trailing slash should not be appended to the base url.
    func test_endpoint_doesNotAppendSlashWhenEmpty() throws {
        // Given
        struct SUT: TestableRequest {
            typealias Resource = String
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
            typealias Resource = String
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

    // MARK: - Query Items Tests

    func test_queryItems_setCorrectly() throws {
        // Given
        struct SUT: TestableRequest {
            typealias Resource = String
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
            typealias Resource = String
            let queryItems: [URLQueryItem] = []
        }
        let request = SUT()

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.url, SUT.defaultTestUrl)
    }

    // MARK: - Header Tests

    func test_headerSetCorrectly() throws {
        // Given
        struct SUT: TestableRequest {
            typealias Resource = String
            let header: Header = [
                Field.accept(.json),
                Field.acceptLanguage("en-scouse")
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
            typealias Resource = String
            let header: Header = .empty
        }
        let request = SUT()

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNotNil(urlRequest.allHTTPHeaderFields)
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, [:])
    }

    // MARK: - Method Tests

    func test_httpMethod_setCorrectly() throws {
        // Given
        let expectedMethod = HTTPMethod.post
        struct SUT: TestableRequest {
            typealias Resource = String
            let method: HTTPMethod
        }
        let request = SUT(method: expectedMethod)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNotNil(urlRequest.httpMethod)
        XCTAssertEqual(urlRequest.httpMethod.map(HTTPMethod.init(rawValue:)), expectedMethod)
    }

    // MARK: - Body Tests

    struct BodyTestRequest: TestableRequest {
        typealias Resource = Void
        let bodyProvider: BodyProvider
    }

    func test_bodyProvider_isInvoked() throws {
        // Given
        var bodyProviderInvoked = false
        let provider = BodyProvider { _ in
            bodyProviderInvoked = true
            return .none
        }
        let request = BodyTestRequest(bodyProvider: provider)

        // When
        _ = try request.toURLRequest()

        // Then
        XCTAssertTrue(bodyProviderInvoked)
    }

    func test_bodyProvider_headerUpdatesAreApplied() throws {
        // Given
        let expectedContentType: Field = .contentType(.svg)
        let provider = BodyProvider { header in
            header.set(expectedContentType)
            return .none
        }
        let request = BodyTestRequest(bodyProvider: provider)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNotNil(urlRequest.value(forHTTPHeaderField: Field.contentType(.svg).name.rawValue.description))
    }

    func test_httpBody_setCorrectlyForNoBody() throws {
        // Given
        let provider = BodyProvider { _ in return .none }
        let request = BodyTestRequest(bodyProvider: provider)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNil(urlRequest.httpBody)
        XCTAssertNil(urlRequest.httpBodyStream)
    }

    func test_httpBody_setCorrectlyForDataBody() throws {
        // Given
        let testData = Data(repeating: 1, count: 10)
        let provider = BodyProvider { _ in return .data(testData) }
        let request = BodyTestRequest(bodyProvider: provider)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNil(urlRequest.httpBodyStream)
        XCTAssertEqual(urlRequest.httpBody, testData)
    }

    func test_httpBody_setCorrectlyForStreamBody() throws {
        // Given
        let testData = Data(repeating: 1, count: 10)
        let testStream = InputStream(data: testData)
        let provider = BodyProvider { _ in return .stream(testStream) }
        let request = BodyTestRequest(bodyProvider: provider)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertNil(urlRequest.httpBody)
        XCTAssertNotNil(urlRequest.httpBodyStream)
        XCTAssertTrue(urlRequest.httpBodyStream! === testStream)
    }

    // MARK: - Authentication Tests

    struct AuthenticationTestRequest: TestableRequest {
        typealias Resource = Void
        let authenticationProvider: AuthenticationProvider
    }

    func test_authenticationProvider_isInvoked() throws {
        // Given
        var invokedAuthenticationProvider = false
        let authProvider = AuthenticationProvider { _ in invokedAuthenticationProvider = true }
        let request = AuthenticationTestRequest(authenticationProvider: authProvider)

        // When
        _ = try request.toURLRequest()

        // Then
        XCTAssertTrue(invokedAuthenticationProvider, "The authentication provider should be invoked")
    }

    func test_authenticationProvider_changesAreApplied() throws {
        // Given
        let expectedAuthFieldValue = "test"
        let authProvider = AuthenticationProvider { $0[.authorization] = expectedAuthFieldValue }
        let request = AuthenticationTestRequest(authenticationProvider: authProvider)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        let authorizationField = Field.Name.authorization.rawValue.description
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?[authorizationField], expectedAuthFieldValue)
    }

    func test_authenticationProvider_isInvokedAfterBodyProvider() throws {
        // Given
        struct SUT: TestableRequest {
            typealias Resource = Void
            let authenticationProvider: AuthenticationProvider
            let bodyProvider: BodyProvider
        }

        var bodyProviderInvoked = false
        var authProviderInvoked = false

        let bodyProvider = BodyProvider { _ in
            XCTAssertFalse(authProviderInvoked,
                           "The authentication provider should not be invoked before the body provider")
            bodyProviderInvoked = true
            return .none
        }

        let authProvider = AuthenticationProvider { _ in
            XCTAssertTrue(bodyProviderInvoked,
                          "The body provider should be invoked before the authentication provider")
            authProviderInvoked = true
        }

        let request = SUT(authenticationProvider: authProvider, bodyProvider: bodyProvider)

        // When
        _ = try request.toURLRequest()

        // Then
        XCTAssertTrue(authProviderInvoked)
        XCTAssertTrue(bodyProviderInvoked)
    }

    // MARK: - Other Attribute Tests

    func test_cachePolicy_setCorrectly() throws {
        // Given
        let expectedPolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        struct SUT: TestableRequest {
            typealias Resource = String
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
            typealias Resource = String
            let timeoutInterval: TimeInterval
        }
        let request = SUT(timeoutInterval: expectedTimeout)

        // When
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.timeoutInterval, expectedTimeout)
    }
}
