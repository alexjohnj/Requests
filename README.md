# Requests

_Requests_ is a small Swift library focused on providing some sugar for building
and organising your application's HTTP requests.

_Requests_ **is not** concerned with the act of performing a network
request. You can use [whatever][urlsession-docs] [you][alamofire-docs]
[want][afnetworking-docs] to perform the requests. _Requests_ simply provides
some types that make building the requests and keeping them organised more
enjoyable.

[urlsession-docs]: https://developer.apple.com/documentation/foundation/urlsession
[alamofire-docs]: https://github.com/Alamofire/Alamofire
[afnetworking-docs]: https://github.com/AFNetworking/AFNetworking

> ⚠️ _Requests_ is under active development and there are some areas of the API
that will change.  The biggest area is how the library handles the body of
requests. _Requests_ currently has no sugar around constructing the body of a
request and has no support for specifying an `InputStream` as the body of a
request. I intend to change the API around request bodies so they can be
declared using a similar method to how response bodies are handled at the
moment.
>
> This change is likely to be an API breaking one, you have been warned.

## Installation

_Requests_ can be installed using [CocoaPods][cocoapods-gh],
[Carthage][carthage-gh] or the [Swift Package Manager][swiftpm-gh]. _Requests_
supports macOS, iOS, tvOS and watchOS.

I suggest using your package manager's [pessimistic
operator][for-a-pessimist-im-pretty-optimistic] to pin the version number to a
minor release while _Requests_ is in the `0.x` phase.

[for-a-pessimist-im-pretty-optimistic]: https://robots.thoughtbot.com/rubys-pessimistic-operator
[cocoapods-gh]: http://cocoapods.org/
[carthage-gh]: https://github.com/carthage/carthage/
[swiftpm-gh]: https://github.com/apple/swift-package-manager


### CocoaPods

Add the following to your `Podfile`:

``` ruby
pod "Requests", "~> 0.1.0"
```

### Carthage

Add the following to your `Cartfile`:

``` ruby
github "alexjohnj/Requests" ~> 0.1.0
```

### Swift Package Manager

Add the following to your `Package.swift` file's dependencies:

``` swift
dependencies: [
    .package(url: "https://github.com/alexjohnj/Requests.git", .upToNextMinor(from: "0.1.0"))
]
```

## General Usage

### Getting Started

For each API you're working with, create a new type that conforms to the
`RequestProviding` protocol and declares the base URL for the API:

``` swift
import Requests

enum ExampleAPI: RequestProviding {
    case development
    case production

    var baseURL: URL {
        switch self {
        case .development:
            return URL("https://dev.api.example.com/v1")
        case .production:
            return URL("https://api.example.com/v1")
        }
    }
}
```

The `ExampleAPI` type will provide the entry point to constructing API
requests. We'll create an `ExampleService` class that uses `ExampleAPI` to
construct requests and a `URLSession` to execute them:

``` swift
class ExampleService {

    let api: ExampleAPI

    private let session: URLSession

    init(api: ExampleAPI, session: URLSession = .shared) {
        self.api = api
        self.session = session
    }
}

```

### `GET`ting a Resource

Suppose we want to retrieve a `User` from our API:

``` swift
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}
```

The `User` lives at the `/users/{{id}}` endpoint which returns a JSON
representation of the `User` struct. We'll add a method to `ExampleService` that
takes care of constructing the request to get a user and sending it to the
URLSession:

``` swift
extension ExampleService {
    func getUser(withId id: Int, completionHandler: @escaping (Result<User>) -> Void) {
        // 1)                |      Response Decoder   |       |   endpoint |
        let request = api.get(.json(encoded: User.self), from: "/users/\(id)")
        // 2)
        session.perform(request, completionHandler: completionHandler)
    }
}
```

The two lines of the `getUser(withId:completionHandler:)` method do quite a bit:

1. Constructs a `GET` request to the `/users/` endpoint and specifies the
[`ResponseDecoder`](#Decoding-a-Response) for the body of the response. The
`.json(encoded:)` decoder is a predefined decoder for `Decodable` types. Note
that the type of `request` is a `Request<ExampleAPI, User>`. The `Request` type
is not only generic over its resource/response (`User`) but also its API
(`ExampleAPI`). More on this in [RequestProviding in
Detail](#RequestProviding-in-Detail).
2. The `perform(_:completionHandler:)` method is an extension on `URLSession`
   provided by _Requests_ that:
   1. Converts a `RequestConvertible` type into a `URLRequest`.
   2. Starts a `URLSessionTask` for the request.
   3. Tries to convert the response body using the request's `ResponseDecoder`.
   4. Invokes the completion handler on the main queue with the result of the
      request.

Not using `URLSession`? Want to use a `Promise<T>` instead of a completion handler?
No problem---See [Performing a Request](#Performing-a-Request) for pointers on
implementing your own wrappers.

We can now make the API request using the `ExampleService` instance we made earlier:

``` swift
service.getUser(withId: 1) { result in
    switch result {
        // (URLResponse, User)
    case .success(let response, let user):
        print(response.statusCode, user.name)
        // (URLResponse, Error)
    case .failed(.some(let response), let error):
        print(response.statusCode, error)
        // (nil, Error)
    case .failed(.none, let error):
        print(error)
    }
}
```

The `result` passed to the completion handler is a `Result<T>` that has _three_ states:

- `sucess` with a `HTTPURLResponse` and a decoded resource from the body of the
  response.
- `failed` with a `HTTPURLResponse` and an error.
- `failed` with an error and no response.

The former error state normally occurs when the request succeeds but the
`ResponseDecoder` fails for some reason. The latter state would indicate that
the request failed due to a client-side error.

### `POST`ing Some Data

Now let's try a different type of request. Let's send a JSON encoded `User` to the API:

``` swift
extension ExampleService {
    func addUser(_ user: User, completionHandler: @escaping (Result<Void>) -> Void) {
        do {
            let encoder = JSONEncoder()
            let encodedUser = try encoder.encode(user)
            let request = api.post(encodedUser, to: "/users")
            session.perform(request, completionHandler: completionHandler)
        } catch {
            DispatchQueue.main.async {
                completionHandler(.failed(nil, error))
            }
        }
    }
}
```

Aside from the encoding step, this is almost identical to the `GET` request in
the previous section. The key difference is the use of the `post(_ body:to:)` method to
construct the request instead of `get(_ decoder:from:)`. As the name suggests,
this constructs a `POST` request that sends some data in the body of the
request. Also note that the response type is `Void`. This indicates that the request
does not expect to receive (or does not care about) a body in the response.

### `RequestProviding` in Detail

The requests shown in the previous sections were both created by the
`RequestProviding` type we created. The `RequestProviding` type for your API is
always the starting point for new requests. It provides several methods to
construct a request:

- `get<NewResource>(_ resourceDecoder: ResponseDecoder<NewResource>, from endpoint: String) -> Request<Self, NewResource>`
- `post(_ body: Data?, to endpoint: String) -> Request<Self, Void>`
- `put(_ body: Data, to endpoint: String) -> Request<Self, Void>`
- `patch(_ endpoint: String, with body: Data) -> Request<Self, Void>`
- `delete(_ endpoint: String) -> Request<Self, Void>`
- `head(_ endpoint: String) -> Request<Self, Void>`

It should be obvious from the method names but these construct a `GET`, `POST`,
`PUT`, `PATCH`, `DELETE` and `HEAD` request respectively. These are all
implemented in terms of a single (optional) protocol method in
`RequestProviding`:

- `request(to endpoint: String, using method: HTTPMethod) -> Request<Self, Void>`

If you need to customise the default headers or query items in requests created
by your request provider, simply implement the `request(to:using:)` method.

Note that all the `Request`s produced by a `RequestProvider` are parameterised
by the provider that created them. This enables you to add extensions on the
`Request` type that are constrained by the API they belong to, allowing you to
build a mini-DSL for your API requests.

### Modifying Requests

The `Request` type has several methods that allow you to add headers, query
parameters and modify the body or response type of the request. All these
methods return a new `Request<API, Resource>` type so they can be chained
together to keep things neat and tidy.

Let's see how you can go about modifying a request. The `POST` request we
defined earlier isn't correct, it doesn't specify the `Content-Type` of the body
and the API actually returns a plain-text status message in the response
body. Let's fix it:

``` swift
extension ExampleService {
    func addUser(_ user: User, completionHandler: @escaping (Result<String>) -> Void) {
        do {
            let encoder = JSONEncoder()
            let encodedUser = try encoder.encode(user)
            let request = api.post(encodedUser, to: "/users")
                .adding(headerField: .contentType("application/json")) // 🆕
                .receiving(.text) // 🆕
            session.perform(request, completionHandler: completionHandler)
        } catch {
            DispatchQueue.main.async {
                completionHandler(.failed(nil, error))
            }
        }
    }
}
```

We've used two new methods here, `adding(headerField:)` and `receiving(_
decoder:)`. The former adds the provided field to the header of the request. The
latter sets the response decoder of the request, changing the response
type. Here we've used the `.text` `ResponseDecoder` which decodes UTF-8 encoded
text from the body of the response.

There are several other modification methods on `Request`. Check out the
generated interface in Xcode for the complete list.

### Decoding a Response

_Requests_ emphasises the relationship between a request and its expected
response. A `Request` knows what its expected response is but it doesn't know
how to decode that response. It defers this to a `ResponseDecoder<T>`. Response
decoders are simple wrappers of a function with the signature `(HTTPURLResponse,
Data) throws -> T`. _Requests_ comes with several predefined decoders:

- `.none` --- Ignores the input data and always returns the `Void`
  value.
- `.data` --- Returns the data passed in to it.
- `.text(encoding:)` --- Decodes a string using the given encoding.
- `.json(encoded:decoder:)` --- Decodes a `Decodable` type from its JSON
  representation.

Adding new decoders is easy. You just write a function that matches the
aforementioned signature and then initialise a new `ResponseDecoder` with
it. Note that all the built in decoders are declared as static properties or
functions on the `ResponseDecoder` type. This allows us to use Swift's type
inference and unqualified member syntax to keep our request definitions nice and
neat. You should do the same thing for your response decoders too.

### `RequestConvertible`

So far all the requests we've dealt with were `Request<API, Resource>`
types. This type is just a big old bag of data with some methods for
mutation. The logic of creating a `URLRequest` from a `Request` is actually
handled by the `RequestConvertible` type.

Types that conform to `RequestConvertible` declare their associated resource
type and all the information needed to construct a request. Note that they _don't_
have an associated `API` type. This is a feature confined to the `Request` type.
By conforming to the `RequestConvertible` protocol and implementing all
the required properties (most are optional), a type can be converted into a
`URLRequest` via the `toURLRequest()` method.

>☝️ If you're writing some functionality that operates on requests in general,
consider using the `RequestConvertible` type instead of `Request`.

The `RequestConvertible` protocol opens up a second way to organise your
application's API requests. Rather than using the `RequestProviding` and
`Request` types' methods to construct a request, you can create a new type for
every request that conforms to `RequestConvertible`. With protocol inheritance,
you can create sensible defaults for your API requests to recreate the features
of the `RequestProviding` protocol:

``` swift
protocol ExampleAPIRequest: RequestConvertible { }
extension ExampleAPIRequest {
    var baseURL: URL { return URL("https://api.example.com/v1") }
}

struct GetUserRequest: ExampleAPIRequest {
    let userId: Int

    typealias Resource = User
    var endpoint: String { return "/users/\(userId)" }
    var method: HTTPMethod { return .get }
    var responseDecoder: ResponseDecoder<User> { return .json() }
}

struct AddUserRequest: ExampleAPIRequest {
    let user: User

    typealias Resource = String // The response decoder is inferred for this request
    var endpoint: String { return "/users" }
    var method: HTTPMethod { return .post }
    var httpBody: Data? { return try? JSONEncoder().encode(user) }
}
```

### Performing a Request

As has already been mentioned, _Requests_ is not concerned with performing
network requests, only the act of constructing them. Saying that, _Requests_
does come with a supported extension on `URLSession` to perform requests. This
is there to help people get up and running with _Requests_ but it is by no means
meant to define how _Requests_ should be used.

If you're integrating _Requests_ with another networking system, keep the
following in mind:

- Constrain your functions to operate on `RequestConvertible`, not `Request<API,
  Resource>`.
- A `Void` resource type indicates the request either doesn't expect or doesn't
  care about the response's body. Your functions should respect this and not
  treat a `nil` response body as an error for `Void` requests.
- `ResponseDecoders` only operate on HTTP responses. Your functions should treat
  non `HTTPURLResponse` instances as an error.
- Converting a `RequestConvertible` type to a `URLRequest` can fail. At the
  moment this happens in the rare case that the conversion between `URL` and
  `URLComponents` fails. In future versions of _Requests_ this might happen
  because encoding the request's body failed. Your functions should not ignore
  the conversion error just because it is currently unlikely to occur.

## License

_Requests_ is licensed under the MIT license.
