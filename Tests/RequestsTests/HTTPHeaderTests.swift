//
//  HTTPHeaderTests.swift
//  Requests
//
//  Created by Alex Jackson on 22/09/2018.
//

import XCTest
import Requests

final class HTTPHeaderTests: XCTestCase {

    func test_headerPatternMatchMatchesSameHeaders() {
        // Given
        let header = HTTPHeader(name: "Content-Type", value: "application/json")
        let pattern = HTTPHeader(name: "Content-Type", value: "application/json")

        // Then
        guard case pattern = header else {
            XCTFail("HTTPHeader pattern \(pattern) should match \(header)")
            return
        }
    }

    func test_headerPatternMatchDoesNotMatchDifferentHeaders() {
        // Given
        let header = HTTPHeader.contentType("application/html")
        let pattern: HTTPHeader = .contentType("text/html")

        // Then
        guard case pattern = header else { return }
        XCTFail("HTTPHeader pattern \(pattern) should not match \(header)")
    }

    func test_headerExplodeMatchesStructure() {
        // Given
        let name = HTTPHeader.Name("Content-Type")
        let value = "application/json"
        let header = HTTPHeader(name: name, value: value)

        // When
        let explodedHeader = header.explode

        // Then
        XCTAssertEqual(explodedHeader.name, name)
        XCTAssertEqual(explodedHeader.value, value)
    }
}
