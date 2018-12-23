//
// Created by Alex Jackson on 2018-12-23.
//

import XCTest
import Requests

final class CaseInsensitiveStringTests: XCTestCase {

    // MARK: - Test Cases

    func test_equality_isCaseInsensitive() {
        // Given
        let stringA = CaseInsensitiveString("test")
        let stringB = CaseInsensitiveString("TeSt")
        let stringC = CaseInsensitiveString("test2")

        // Then
        XCTAssertEqual(stringA, stringB)
        XCTAssertEqual(stringB, stringA)
        XCTAssertNotEqual(stringA, stringC)
    }

    func test_hashable_isCaseInsensitive() {
        // Given
        let stringA = CaseInsensitiveString("test")
        let stringB = CaseInsensitiveString("TeSt")
        let stringC = CaseInsensitiveString("test2")

        // Then
        XCTAssertEqual(stringA.hashValue, stringB.hashValue)
        XCTAssertEqual(stringB.hashValue, stringA.hashValue)
        XCTAssertNotEqual(stringA.hashValue, stringC.hashValue)
        XCTAssertNotEqual(stringB.hashValue, stringC.hashValue)
    }

    func test_comparable_isCaseInsensitive() {
        // Given
        let stringA = "c"
        let stringB = "B"
        let stringC = "C"

        // Then
        XCTAssertTrue(stringA > stringB)
        XCTAssertTrue(stringB < stringC)
    }
}
