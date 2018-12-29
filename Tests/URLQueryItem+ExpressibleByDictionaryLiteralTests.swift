//
// Created by Alex Jackson on 2018-11-22.
//

import Foundation
import XCTest

import Requests

internal final class URLQueryItemDictionaryLiteralTests: XCTestCase {

    // MARK: - Test Cases

    func test_initializer_works() {
        // Given
        let expectedItems = [
            URLQueryItem(name: "test", value: "value"),
            URLQueryItem(name: "test2", value: nil),
            URLQueryItem(name: "test", value: "duplicate")
        ]
        let testItems: [URLQueryItem] = [
            "test": "value",
            "test2": nil,
            "test": "duplicate"
        ]

        // Then
        XCTAssertEqual(testItems, expectedItems)
    }
}
