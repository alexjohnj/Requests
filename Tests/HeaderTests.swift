//
// Created by Alex Jackson on 29/09/2018.
//

import XCTest
import Requests

final class HeaderTests: XCTestCase {

    // MARK: - Initializers

    func test_initFromArray_Works() {
        // Given, When
        let fields: [Field] = [
            .contentType(.json),
            .acceptLanguage("en_GB"),
            .accept("text/html")
        ]
        let header = Header(fields)

        // Then
        XCTAssertEqual(header[.contentType], MediaType.json.rawValue)
        XCTAssertEqual(header[.acceptLanguage], "en_GB")
        XCTAssertEqual(header[.accept], "text/html")
    }

    func test_initFromArray_WithDuplicateFieldNames_GroupsValuesWithComma() {
        // Given, When
        let fields: [Field] = [
            .accept("text/html"),
            .accept("application/json")
        ]
        let header = Header(fields)

        // Then
        XCTAssertEqual(header[.accept], "text/html,application/json")
    }

    func test_initFromArrayLiteral_Works() {
        // Given, When
        let header: Header = [
            .contentType(.json),
            .acceptLanguage("en_GB")
        ]

        // Then
        XCTAssertEqual(header[.contentType], MediaType.json.rawValue)
        XCTAssertEqual(header[.acceptLanguage], "en_GB")
    }

    func test_initFromVariadic_Works() {
        // Given, When
        let header = Header(.contentType(.json), .accept("en_GB"))

        // Then
        XCTAssertEqual(header[.contentType], MediaType.json.rawValue)
        XCTAssertEqual(header[.accept], "en_GB")
    }

    // MARK: - Add Method

    func test_add_addsFieldToHeader() {
        // Given
        var header = Header()

        // When
        header.add(.contentType(.html))

        // Then
        XCTAssertEqual(header[.contentType], MediaType.html.rawValue)
    }

    func test_add_joinsDuplicateFieldsWithComma() {
        // Given
        var header: Header = [.accept("text/html")]

        // When
        header.add(.accept("application/json"))

        // Then
        XCTAssertEqual(header[.accept], "text/html,application/json")
    }

    // MARK: - Set Method

    func test_set_addsNewFieldToHeader() {
        // Given
        var header = Header()

        // When
        header.set(.accept("text/html"))

        // Then
        XCTAssertEqual(header[.accept], "text/html")
    }

    func test_set_replacesExistingFieldValue() {
        // Given
        var header: Header = [.accept("application/json")]

        // When
        header.set(.accept("text/html"))

        // Then
        XCTAssertEqual(header[.accept], "text/html")
    }

    // MARK: - Remove Method

    func test_remove_returnsNilIfFieldNameIsNotInHeader() {
        // Given, When, Then
        var header = Header(.contentType(.json))
        XCTAssertNil(header.remove(.accept))
    }

    func test_remove_doesNotEffectHeaderIfFieldNameIsNotInHeader() {
        // Given
        var header = Header(.contentType(.json))
        let copy = header

        // When
        header.remove(.accept)

        // Then
        XCTAssertEqual(header, copy)
    }

    func test_remove_removesMatchingField() {
        // Given
        var header = Header(.contentType(.json))

        // When
        header.remove(.contentType)

        // Then
        XCTAssertFalse(header.contains(.contentType))
    }

    func test_remove_returnsMatchingField() {
        // Given
        let field = Field.contentType(.json)
        var header = Header(field)

        // When
        let removedField = header.remove(.contentType)

        // Then
        XCTAssertEqual(removedField, field)
    }

    // MARK: - Contains Method

    func test_contains_returnsFalseForNonExistentField() {
        // Given
        let header = Header()

        // When, Then
        XCTAssertFalse(header.contains(.accept))
    }

    func test_contains_returnsTrueForExistingField() {
        // Given
        let header: Header = [.contentType(.html)]

        // When, Then
        XCTAssertTrue(header.contains(.contentType))
    }

    // MARK: - Dictionary Value Property

    func test_dictionaryValue_containsAllValues() {
        // Given, When
        let header: Header = [
            .contentType(.json),
            .accept("text/html")
        ]
        let dictHeader = header.dictionaryValue
        let expectedValue = [
            String(describing: Field.Name.contentType.rawValue): MediaType.json.rawValue,
            String(describing: Field.Name.accept.rawValue): "text/html"
        ]

        // Then
        XCTAssertEqual(dictHeader, expectedValue)
    }

    // MARK: - isEmpty Property

    func test_isEmpty() {
        // Given, When
        let header = Header()

        // Then
        XCTAssertTrue(header.isEmpty)
    }
}
