//
// Created by Alex Jackson on 2018-11-25.
//

import Foundation

public enum Result<Resource> {
    case success(HTTPURLResponse, Resource)
    case failed(HTTPURLResponse?, Error)
}
