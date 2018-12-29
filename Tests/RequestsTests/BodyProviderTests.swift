//
// Created by Alex Jackson on 2018-12-27.
//

import XCTest
import Foundation
import Requests

final class BodyProviderTests: XCTestCase {

    // MARK: - None Body Provider

    func test_noneProvider_producesNoBody() throws {
        // Given
        var header = Header.empty
        let provider = BodyProvider.none

        // When
        let body = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(body, .none)
    }

    func test_noneProvider_clearsContentType() throws {
        // Given
        var header = Header([.contentType(.json)])
        let provider = BodyProvider.none

        // When
        _ = try provider.body(updating: &header)

        // Then
        XCTAssertNil(header[.contentType])
    }

    // MARK: - Raw Body Providers

    func test_rawDataProvider_updatesContentType() throws {
        // Given
        let expectedContentType = MediaType.png
        var header = Header.empty
        let provider = BodyProvider.raw(data: Data(), contentType: expectedContentType)

        // When
        _ = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(header[.contentType], expectedContentType.rawValue)
    }

    func test_rawDataProvider_producesCorrectBody() throws {
        // Given
        let expectedData = Data()
        var header = Header.empty
        let provider = BodyProvider.raw(data: expectedData)

        // When
        let body = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(body, .data(expectedData))
    }

    func test_rawStreamProvider_updatesContentType() throws {
        // Given
        let expectedContentType = MediaType.png
        var header = Header.empty
        let provider = BodyProvider.raw(stream: InputStream(data: Data()), contentType: expectedContentType)

        // When
        _ = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(header[.contentType], expectedContentType.rawValue)
    }

    func test_rawStreamProvider_producesCorrectBody() throws {
        // Given
        let expectedStream = InputStream(data: Data())
        var header = Header.empty
        let provider = BodyProvider.raw(stream: expectedStream)

        // When
        let body = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(body, .stream(expectedStream))
    }

    // MARK: - Text Provider

    func test_textProvider_setsContentType() throws {
        // Given
        var header = Header.empty
        let provider = BodyProvider.text("test")

        // When
        _ = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(header[.contentType], MediaType.plainText.rawValue)
    }

    func test_textProvider_producesCorrectBody() throws {
        // Given
        let testText = "test"
        let expectedBody = testText.data(using: .utf8)!
        var header = Header.empty
        let provider = BodyProvider.text(testText)

        // When
        let body = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(body, .data(expectedBody))
    }

    // MARK: - JSON Provider

    private struct TestBody: Encodable {
        let value: String
    }

    func test_jsonProvider_setsContentType() throws {
        // Given
        var header = Header.empty
        let provider = BodyProvider.json(encoded: TestBody(value: "test"))

        // When
        _ = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(header[.contentType], MediaType.json.rawValue)
    }

    func test_jsonProvider_producesCorrectBody() throws {
        // Given
        let encoder = JSONEncoder()
        let testValue = TestBody(value: "test")
        let expectedBody = try encoder.encode(testValue)
        var header = Header.empty
        let provider = BodyProvider.json(encoded: testValue, using: encoder)

        // When
        let body = try provider.body(updating: &header)

        // Then
        XCTAssertEqual(body, .data(expectedBody))
    }
}
