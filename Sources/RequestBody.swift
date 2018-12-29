//
// Created by Alex Jackson on 2018-12-23.
//

import Foundation

/// The body of a `RequestConvertible` type.
public enum RequestBody {

    /// An empty/non-existent body.
    case none

    /// A body consisting of the wrapped data.
    case data(Data)

    /// A body whose data is provided by the wrapped stream.
    case stream(InputStream)
}

extension RequestBody: Equatable { }
