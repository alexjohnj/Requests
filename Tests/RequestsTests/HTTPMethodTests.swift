//
//  HTTPMethodTests.swift
//  Requests
//
//  Created by Alex Jackson on 22/09/2018.
//

import XCTest
import Requests

final class HTTPMethodTests: XCTestCase {

    func test_patternMatchingOperatorMatchesOnSameMethods() {
        // Given
        let method = HTTPMethod.get

        // Then
        guard case .get = method else {
            XCTFail("HTTPMethod pattern \(HTTPMethod.get) should match \(method)")
            return
        }
    }

    func test_patternMatchingOperatorDOesntMatchOnDifferentMethods() {
        // Given
        let method = HTTPMethod.get

        // Then
        guard case .put = method else {
            return
        }

        XCTFail("HTTPMethod pattern \(HTTPMethod.put) should not match \(method)")
    }
}
