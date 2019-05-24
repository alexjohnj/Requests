//
// Created by Alex Jackson on 2019-02-27.
//

import XCTest
import Requests

final class AuthenticationProviderTests: XCTestCase {

    // MARK: - Test Cases

    func test_noneProvider_preservesExistingAuthenticationField() {
        // Given
        let provider = AuthenticationProvider.none
        var header = Header(Field(name: .authorization, value: "something"))

        // When
        provider.update(&header)

        // Then
        XCTAssertEqual(header[.authorization], "something")
    }

    func test_bearerProvider() {
        // Given
        let token = "test-token"
        let provider = AuthenticationProvider.bearerToken(token)
        var header = Header.empty

        // When
        provider.update(&header)

        // Then
        XCTAssertEqual(header[.authorization], "Bearer \(token)")
    }

    func test_basicProvider() {
        // Given
        let username = "user"
        let password = "password"
        let expectedAuthFieldValue = "Basic dXNlcjpwYXNzd29yZA=="
        let provider = AuthenticationProvider.basicAuth(username: username, password: password)
        var header = Header.empty

        // When
        provider.update(&header)

        // Then
        XCTAssertEqual(header[.authorization], expectedAuthFieldValue)
    }
}
