//
// Created by Alex Jackson on 2018-12-23.
//

import XCTest
import Requests

final class MediaTypeTests: XCTestCase {

    func test_stringValue_isCorrectWithoutParameters() {
        let mediaType = MediaType(type: .text, subtype: .plain)
        let expectedRawValue = "text/plain"

        XCTAssertEqual(mediaType.rawValue, expectedRawValue)
    }

    func test_stringValue_isCorrectWithParameters() {
        let mediaType = MediaType(type: .text, subtype: .plain, parameters: ["charset": "utf8", "format": "flowed"])
        let expectedRawValueA = "text/plain; charset=utf8; format=flowed"
        let expectedRawValueB = "text/plain; format=flowed; charset=utf8"

        let rawValue = mediaType.rawValue

        // Can't guarantee parameter ordering so check both possibilities
        XCTAssertTrue(rawValue == expectedRawValueA || rawValue == expectedRawValueB)
    }

    func test_equatable_doesNotIncludeParameters() {
        let mediaTypeA = MediaType(type: .text, subtype: .plain)
        let mediaTypeB = MediaType(type: .text, subtype: .plain, parameters: ["charset": "utf8"])
        let mediaTypeC = MediaType(type: .text, subtype: .plain, parameters: ["format": "flowed"])

        XCTAssertEqual(mediaTypeA, mediaTypeB)
        XCTAssertEqual(mediaTypeA, mediaTypeC)
        XCTAssertEqual(mediaTypeB, mediaTypeC)
    }

    func test_hashable_doesNotIncludeParameters() {
        let mediaTypeA = MediaType(type: .text, subtype: .plain)
        let mediaTypeB = MediaType(type: .text, subtype: .plain, parameters: ["charset": "utf8"])
        let mediaTypeC = MediaType(type: .text, subtype: .plain, parameters: ["format": "flowed"])

        XCTAssertEqual(mediaTypeA.hashValue, mediaTypeB.hashValue)
        XCTAssertEqual(mediaTypeA.hashValue, mediaTypeC.hashValue)
        XCTAssertEqual(mediaTypeB.hashValue, mediaTypeC.hashValue)
    }

}
