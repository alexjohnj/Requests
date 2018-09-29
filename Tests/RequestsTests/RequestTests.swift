//
//  RequestTests.swift
//  RequestsTests
//
//  Created by Alex Jackson on 23/09/2018.
//

import XCTest
import Requests

struct TestRequest: Request {
    var cachePolicy: URLRequest.CachePolicy { return .useProtocolCachePolicy }

    var timeoutInterval: TimeInterval {
        return 60
    }


    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    var endpoint: String {
        return "/users"
    }

    var method: HTTPMethod {
        return .put
    }

    var header: Header {
        return [
            .contentType("application/json")
        ]
    }

    var queryParameters: [String : String]? { return nil }

    var httpBody: Data? { return nil }

    typealias Response = Data

}

class RequestTests: XCTestCase {

}
