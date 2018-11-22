//
// Created by Alex Jackson on 2018-11-22.
//

import Foundation

extension URL {

    /// Initialises a new URL from a static string. Panics if the URL in the static string is invalid.
    public init(_ string: StaticString) {
        guard let maybeSelf = URL(string: String(staticString: string)) else {
            preconditionFailure("\(string) is not a valid URL")
        }

        self = maybeSelf
    }
}

extension String {
    fileprivate init(staticString: StaticString) {
        self = staticString.withUTF8Buffer { String(decoding: $0, as: UTF8.self) }
    }
}
