//
//  FieldTests.swift
//  Requests
//
//  Created by Alex Jackson on 22/09/2018.
//

import XCTest
import Requests

final class FieldTests: XCTestCase {

    func test_fieldPatternMatchMatchesSameField() {
        // Given
        let field = Field.contentType("text/html")
        let pattern = field

        // Then
        guard case pattern = field else {
            XCTFail("\(Field.self) pattern '\(pattern)' should match '\(field)'")
            return
        }
    }

    func test_fieldPatternMatchDoesNotMatchDifferentField() {
        // Given
        let field = Field.contentType("application/html")
        let pattern: Field = .contentType("text/html")

        // Then
        guard case pattern = field else { return }
        XCTFail("\(Field.self) pattern '\(pattern)' should not match '\(field)'")
    }

    func test_fieldExplodeMatchesStructure() {
        // Given
        let name = Field.Name("Content-Type")
        let value = "application/json"
        let field = Field(name: name, value: value)

        // When
        let explodedField = explode(field)

        // Then
        XCTAssertEqual(explodedField.name, name)
        XCTAssertEqual(explodedField.value, value)
    }

    func test_FieldNameEqualityIsCaseInsensitive() {
        // Given
        let name = Field.Name("Content-Type")
        let name2 = Field.Name("CONTENT-TYPE")
        let name3 = Field.Name("type-CONTENT")

        // Then
        XCTAssertEqual(name, name2)
        XCTAssertNotEqual(name, name3)
        XCTAssertNotEqual(name2, name3)
    }

    func test_FieldNameHashIsCaseInsensitive() {
        // Given
        let name = Field.Name("Content-Type")
        let name2 = Field.Name("CONTENT-TYPE")
        let name3 = Field.Name("type-CONTENT")

        // Then
        XCTAssertEqual(name.hashValue, name2.hashValue)
        XCTAssertNotEqual(name.hashValue, name3.hashValue)
        XCTAssertNotEqual(name2.hashValue, name3.hashValue)
    }
}
