//
// Created by Alex Jackson on 29/09/2018.
//

import XCTest
import Nimble
import Requests

final class HeaderTests: XCTestCase {

    // MARK: - Initializers

    func test_initFromArray_Works() {
        // Given, When
        let fields: [Field] = [
            .contentType("application/json"),
            .acceptLanguage("en_GB"),
            .accept("text/html")
        ]
        let header = Header(fields)

        // Then
        expect(header[.contentType]).to(equal("application/json"))
        expect(header[.acceptLanguage]).to(equal("en_GB"))
        expect(header[.accept]).to(equal("text/html"))
    }

    func test_initFromArray_WithDuplicateFieldNames_GroupsValuesWithComma() {
        // Given, When
        let fields: [Field] = [
            .accept("text/html"),
            .accept("application/json")
        ]
        let header = Header(fields)

        // Then
        expect(header[.accept]).to(equal("text/html,application/json"))
    }

    func test_initFromArrayLiteral_Works() {
        // Given, When
        let header: Header = [
            .contentType("application/json"),
            .acceptLanguage("en_GB")
        ]

        // Then
        expect(header[.contentType]).to(equal("application/json"))
        expect(header[.acceptLanguage]).to(equal("en_GB"))
    }

    func test_initFromVariadic_Works() {
        // Given, When
        let header = Header(.contentType("application/json"), .accept("en_GB"))

        // Then
        expect(header[.contentType]).to(equal("application/json"))
        expect(header[.accept]).to(equal("en_GB"))
    }

    // MARK: - Add Method

    func test_add_addsFieldToHeader() {
        // Given
        var header = Header()

        // When
        header.add(.contentType("text/html"))

        // Then
        expect(header[.contentType]).to(equal("text/html"))
    }

    func test_add_joinsDuplicateFieldsWithComma() {
        // Given
        var header: Header = [.accept("text/html")]

        // When
        header.add(.accept("application/json"))

        // Then
        expect(header[.accept]).to(equal("text/html,application/json"))
    }

    // MARK: - Set Method

    func test_set_addsNewFieldToHeader() {
        // Given
        var header = Header()

        // When
        header.set(.accept("text/html"))

        // Then
        expect(header[.accept]).to(equal("text/html"))
    }

    func test_set_replacesExistingFieldValue() {
        // Given
        var header: Header = [.accept("application/json")]

        // When
        header.set(.accept("text/html"))

        // Then
        expect(header[.accept]).to(equal("text/html"))
    }

    // MARK: - Remove Method

    func test_remove_returnsNilIfFieldNameIsNotInHeader() {
        // Given, When, Then
        var header = Header(.contentType("application/json"))
        expect(header.remove(.accept)).to(beNil())
    }

    func test_remove_doesNotEffectHeaderIfFieldNameIsNotInHeader() {
        // Given
        var header = Header(.contentType("application/json"))
        let copy = header

        // When
        header.remove(.accept)

        // Then
        expect(header).to(equal(copy))
    }

    func test_remove_removesMatchingField() {
        // Given
        var header = Header(.contentType("application/json"))

        // When
        header.remove(.contentType)

        // Then
        expect(header.contains(.contentType)).to(beFalse())
    }

    func test_remove_returnsMatchingField() {
        // Given
        let field = Field.contentType("application/json")
        var header = Header(field)

        // When
        let removedField = header.remove(.contentType)

        // Then
        expect(removedField).to(equal(field))
    }

    // MARK: - Contains Method

    func test_contains_returnsFalseForNonExistentField() {
        // Given
        let header = Header()

        // When, Then
        expect(header.contains(.accept)).to(beFalse())
    }

    func test_contains_returnsTrueForExistingField() {
        // Given
        let header: Header = [.contentType("text/html")]

        // When, Then
        expect(header.contains(.contentType)).to(beTrue())
    }

    // MARK: - Dictionary Value Property

    func test_dictionaryValue_containsAllValues() {
        // Given, When
        let header: Header = [
            .contentType("application/json"),
            .accept("text/html")
        ]
        let dictHeader = header.dictionaryValue
        let expectedValue = [
            Field.Name.contentType.rawValue: "application/json",
            Field.Name.accept.rawValue: "text/html"
        ]

        // Then
        expect(dictHeader).to(equal(expectedValue))
    }
}
