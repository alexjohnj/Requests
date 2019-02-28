//
// Created by Alex Jackson on 2018-11-27.
//

import Foundation
import XCTest
import Requests

final class RequestTests: XCTestCase {

    // MARK: - Private Properties

    private let baseURL = URL("https://example.com")

    private let api = AnonymousRequestProvider("https://example.com")

    // MARK: - Test Cases

    // MARK: Request Creation

    func test_get_setsEndpointAndMethod() {
        // Given
        let expectedEndpoint = "/get"
        let expectedMethod = HTTPMethod.get

        // When
        let getRequest = api.get(.text, from: expectedEndpoint)

        // Then
        XCTAssertEqual(getRequest.endpoint, expectedEndpoint)
        XCTAssertEqual(getRequest.method, expectedMethod)
    }

    func test_post_setsEndpointAndBodyAndMethod() throws {
        // Given
        let expectedBody = "Hello, world".data(using: .utf8)!
        let expectedEndpoint = "/post"
        let expectedMethod = HTTPMethod.post

        // When
        let request = api.post(.raw(data: expectedBody), to: expectedEndpoint)
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(request.endpoint, expectedEndpoint)
        XCTAssertEqual(request.method, expectedMethod)
        XCTAssertEqual(urlRequest.httpBody, expectedBody)
    }

    func test_put_setsEndpointAndBodyAndMethod() throws {
        // Given
        let expectedBody = "Hello, world".data(using: .utf8)!
        let expectedEndpoint = "/put"
        let expectedMethod = HTTPMethod.put

        // When
        let request = api.put(.raw(data: expectedBody), to: expectedEndpoint)
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(request.endpoint, expectedEndpoint)
        XCTAssertEqual(request.method, expectedMethod)
        XCTAssertEqual(urlRequest.httpBody, expectedBody)
    }

    func test_patch_setsEndpointAndBodyAndMethod() throws {
        // Given
        let expectedBody = "Hello, world".data(using: .utf8)!
        let expectedEndpoint = "/patch"
        let expectedMethod = HTTPMethod.patch

        // When
        let request = api.patch(expectedEndpoint, with: .raw(data: expectedBody))
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(request.endpoint, expectedEndpoint)
        XCTAssertEqual(request.method, expectedMethod)
        XCTAssertEqual(urlRequest.httpBody, expectedBody)
    }

    func test_delete_setsEndpointAndMethod() {
        // Given
        let expectedEndpoint = "/delete"
        let expectedMethod = HTTPMethod.delete

        // When
        let deleteRequest = api.delete(expectedEndpoint)

        // Then
        XCTAssertEqual(deleteRequest.endpoint, expectedEndpoint)
        XCTAssertEqual(deleteRequest.method, expectedMethod)
    }

    func test_head_setsEndpointAndMethod() {
        // Given
        let expectedEndpoint = "/head"
        let expectedMethod = HTTPMethod.head

        // When
        let headRequest = api.head(expectedEndpoint)

        // Then
        XCTAssertEqual(headRequest.endpoint, expectedEndpoint)
        XCTAssertEqual(headRequest.method, expectedMethod)
    }

    func test_requestTo_setsEndpointAndMethod() {
        // Given
        let expectedEndpoint = "/custom"
        let expectedMethod: HTTPMethod = "CUSTOM"

        // When
        let customRequest = api.request(to: expectedEndpoint, using: expectedMethod)

        // Then
        XCTAssertEqual(customRequest.endpoint, expectedEndpoint)
        XCTAssertEqual(customRequest.method, expectedMethod)
    }

    // MARK: Method  Manipulation

    func test_usingMethod_updatesMethod() {
        // Given
        let request = api.request(to: "/test", using: .post)
        let expectedMethod = HTTPMethod.options

        // When
        let newRequest = request.using(method: expectedMethod)

        // Then
        XCTAssertEqual(newRequest.method, expectedMethod)
    }

    // MARK: Header Manipulation

    func test_withHeader_setsHeader() {
        // Given
        let expectedHeader = Header(
          [
              .contentType(.json),
              .acceptLanguage("en-scouse")
          ])

        // When
        let request = api.request(to: "/test", using: .get).with(header: expectedHeader)

        // Then
        XCTAssertEqual(request.header, expectedHeader)
    }

    func test_addingHeaderField_addsNewField() {
        // Given
        let initialField = Field.acceptLanguage("en-scouse")
        let testField = Field.contentType(.json)
        let expectedHeader = Header(initialField, testField)

        // When
        let request = api.request(to: "/test", using: .get)
          .with(header: [initialField])
          .adding(headerField: testField)

        // Then
        XCTAssertEqual(request.header, expectedHeader)
    }

    func test_addingHeaderField_mergesExistingField() {
        // Given
        let initialHeader = Header(.acceptLanguage("en-gb"))
        let testField = Field.acceptLanguage("en-scouse")
        var expectedHeader = initialHeader
        expectedHeader.add(testField)

        // When
        let request = api.request(to: "/test", using: .get)
            .with(header: initialHeader)
            .adding(headerField: testField)

        // Then
        XCTAssertEqual(request.header, expectedHeader)
    }

    func test_settingHeaderField_addsNewField() {
        // Given
        let initialHeader = Header(.acceptLanguage("en-scouse"))
        let testField = Field.contentType(.json)
        var expectedHeader = initialHeader
        expectedHeader.set(testField)

        // When
        let request = api.request(to: "/test", using: .get)
          .with(header: initialHeader)
          .setting(headerField: testField)

        // Then
        XCTAssertEqual(request.header, expectedHeader)
    }

    func test_settingHeaderField_replacesExistingField() {
        // Given
        let initialHeader = Header(.acceptLanguage("en-gb"))
        let testField = Field.acceptLanguage("en-scouse")
        var expectedHeader = initialHeader
        expectedHeader.set(testField)

        // When
        let request = api.request(to: "/test", using: .get)
          .with(header: initialHeader)
          .setting(headerField: testField)

        // Then
        XCTAssertEqual(request.header, expectedHeader)
    }

    func test_addingHeaderFieldsArray_addsNewFields() {
        // Given
        let initialHeader = Header(.acceptLanguage("en-scouse"))
        let newFields: [Field] = [.acceptLanguage("en-gb"), .contentType(.json)]
        var expectedHeader = initialHeader
        newFields.forEach { expectedHeader.add($0) }

        // When
        let request = api.request(to: "/test", using: .get)
            .with(header: initialHeader)
            .adding(headerFields: newFields)

        // Then
        XCTAssertEqual(request.header, expectedHeader)
    }

    func test_addingHeaderFieldsVariadic_addsNewFields() {
        // Given
        let initialHeader = Header(.acceptLanguage("en-scouse"))
        let newField1 = Field.acceptLanguage("en-gb")
        let newField2 = Field.contentType(.json)

        var expectedHeader = initialHeader
        expectedHeader.add(newField1)
        expectedHeader.add(newField2)

        // When
        let request = api.request(to: "/test", using: .get)
          .with(header: initialHeader)
          .adding(headerFields: newField1, newField2)

        // Then
        XCTAssertEqual(request.header, expectedHeader)
    }

    // MARK: - Query Manipulation

    func test_withQuery_setsQuery() {
        // Given
        let expectedQuery: [URLQueryItem] = [
            "test": "test_value",
            "test": "otherValue"
        ]

        // When
        let request = api.request(to: "/test", using: .get).with(query: expectedQuery)

        // Then
        XCTAssertEqual(request.queryItems, expectedQuery)
    }

    func test_addingQuery_addsNewItem() {
        // Given
        let testQuery = URLQueryItem(name: "test_2", value: "test_value_2")
        let initialQuery = [URLQueryItem(name: "test", value: "test_value")]
        let expectedQuery = initialQuery + [testQuery]

        // When
        let request = api.request(to: "/test", using: .get)
          .with(query: initialQuery)
          .adding(queryItem: testQuery)

        // Then
        XCTAssertEqual(request.queryItems, expectedQuery)
    }

    func test_addingQueryItemsArray_addsNewItems() {
        // Given
        let initialQuery: [URLQueryItem] = [
            "test": "test_value",
            "test_2": "test_value_2"
        ]
        let appendedQuery: [URLQueryItem] = [
            "test_3": "test_value_3",
            "test_4": "test_value_4",
        ]
        let expectedQuery = initialQuery + appendedQuery

        // When
        let request = api.request(to: "/test", using: .get)
            .with(query: initialQuery)
            .adding(queryItems: appendedQuery)

        // Then
        XCTAssertEqual(request.queryItems, expectedQuery)
    }

    func test_addingQueryItemsVariadic_addsNewItems() {
        // Given
        let initialQuery: [URLQueryItem] = [
            "test": "test_value",
            "test_2": "test_value_2"
        ]
        let appendedQueryItem1 = URLQueryItem(name: "test_3", value: "test_value_3")
        let appendedQueryItem2 = URLQueryItem(name: "test_4", value: "test_value_4")
        let expectedQuery = initialQuery + [appendedQueryItem1, appendedQueryItem2]

        // When
        let request = api.request(to: "/test", using: .get)
          .with(query: initialQuery)
          .adding(queryItems: appendedQueryItem1, appendedQueryItem2)

        // Then
        XCTAssertEqual(request.queryItems, expectedQuery)
    }

    // MARK: - Body Manipulation

    func test_sendingBody_setsBody() throws {
        // Given
        let expectedBody = "Hello, world!".data(using: .utf8)!

        // When
        let request = api.request(to: "/test", using: .post).sending(.raw(data: expectedBody))
        let urlRequest = try request.toURLRequest()

        // Then
        XCTAssertEqual(urlRequest.httpBody, expectedBody)
    }

    // MARK: - Request Configuration Manipulation

    func test_timeoutAfter_setsTimeout() {
        // Given
        let expectedTimeout: TimeInterval = 42

        // When
        let request = api.request(to: "/test", using: .get).timeout(after: expectedTimeout)

        // Then
        XCTAssertEqual(request.timeoutInterval, expectedTimeout)
    }

    func test_authenticatedWith_setsAuthenticationProvider() throws {
        // Given
        let expectedAuthFieldValue = "test"
        let authenticationProvider = AuthenticationProvider { $0[.authorization] = expectedAuthFieldValue }

        // When
        let request = api.request(to: "/test", using: .get).authenticated(with: authenticationProvider)
        let urlRequest = try request.toURLRequest()

        // Then
        let authorizationField = Field.Name.authorization.rawValue.description
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?[authorizationField], expectedAuthFieldValue)
    }
}
