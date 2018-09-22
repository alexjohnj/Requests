//
//  HTTPHeader.swift
//  Requests
//
//  Created by Alex Jackson on 22/09/2018.
//

public struct HTTPHeader: Hashable {

    public let name: String

    public let value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

extension HTTPHeader {
    public static func ~= (pattern: HTTPHeader, value: HTTPHeader) -> Bool {
        return pattern == value
    }
}
