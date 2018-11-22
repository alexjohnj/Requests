//
// Created by Alex Jackson on 2018-11-22.
//

import Foundation

extension Array: ExpressibleByDictionaryLiteral where Element == URLQueryItem {

    public typealias Key = String

    public typealias Value = String?

    /// Initialises an array of URLQueryItems from a collection of key/value pairs.
    public init(dictionaryLiteral elements: (String, String?)...) {
        self.init(elements.map(URLQueryItem.init))
    }
}
