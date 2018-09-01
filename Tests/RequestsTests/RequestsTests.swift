import XCTest
import Foundation
@testable import Requests

struct TestResource { }

final class RequestsTests: XCTestCase {

    let baseRequest = Request<Void>(to: "api.github.com")!

    func testUsing() {
        // Given
        let getRequest = baseRequest.using(method: .get)
        let postRequest = baseRequest.using(method: .post)

        // Then
        XCTAssertEqual(getRequest.method, .get)
        XCTAssertEqual(postRequest.method, .post)
    }

    func testToEndpointSetsPath() {
        // Given
        let usersRequest = baseRequest.for(endpoint: "/users")

        // Then
        XCTAssertEqual(usersRequest.path, "/users")
    }

    func testToEndpointOverwritesExistingPath() {
        // Given
        let usersRequest = baseRequest.for(endpoint: "/users")
        let repositoriesRequest = usersRequest.for(endpoint: "/repositories")

        // Then
        XCTAssertEqual(repositoriesRequest.path, "/repositories")
    }

    func anotherTest() {
        let request =
          BaseRequest(to: "api.github.com/test")!
            .for(resource: TestResource.self)
            .using(method: .get)
    }
}
