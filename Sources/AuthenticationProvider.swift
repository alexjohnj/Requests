//
// Created by Alex Jackson on 2019-02-27.
//

import Foundation

public struct AuthenticationProvider {

    private let _body: (inout Header) -> Void

    public init(authenticate: @escaping (inout Header) -> Void) {
        self._body = authenticate
    }

    public func update(_ header: inout Header) {
        _body(&header)
    }
}

extension AuthenticationProvider {

    /// An authentication provider that makes no changes to the header passed to it.
    public static let none = AuthenticationProvider(authenticate: { _ in })

    /// An authentication provider that sets the provided token as a bearer token in the header.
    public static let bearerToken: (String) -> AuthenticationProvider = { token in
        AuthenticationProvider { header in
            header[.authorization] = "Bearer \(token)"
        }
    }

    /// Adds a basic `Authorization` header field to the header using the provided username and password.
    public static func basicAuth(username: String, password: String) -> AuthenticationProvider {
        return AuthenticationProvider { header in
            let base64Token = "\(username):\(password)".data(using: .utf8)?.base64EncodedString()
            let authorizationValue = base64Token.map { "Basic \($0)" }
            header[.authorization] = authorizationValue
        }
    }
}
