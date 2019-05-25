# Requests [![Build Status](https://app.bitrise.io/app/5a6709f831604876/status.svg?token=IhVpUeUB9JduoFGCyhR6Uw&branch=master)](https://app.bitrise.io/app/5a6709f831604876)

_Requests_ is a Swift library focused on providing sugar for building and
organising your application's HTTP requests.

_Requests_ **is not** concerned with performing network requests. You can use
[whatever][urlsession-docs] [you][alamofire-docs] [want][afnetworking-docs] to
perform the requests. _Requests_ simply provides some types that make building
requests and keeping them organised more enjoyable.

[urlsession-docs]: https://developer.apple.com/documentation/foundation/urlsession
[alamofire-docs]: https://github.com/Alamofire/Alamofire
[afnetworking-docs]: https://github.com/AFNetworking/AFNetworking

> ⚠️ _Requests_ is under active development and there are some areas of the API
> that will change. Until _Requests_ reaches version 1.0, any non patch 0.x
> release can be API breaking.

---

# Usage Guide

## Core Types

_Requests_ contains a few types that form the core of the library as well as
many helper types. Complete reference documentation for all types can be found
[here](https://alexjohnj.github.io/Requests).

The core types are:

- The `RequestConvertible` protocol --- Conforming types declare the properties
  of a HTTP request and can be converted into Foundation `URLRequest` instances.
- The `Request` structure --- A concrete implementation of the
  `RequestConvertible` protocol that provides a fluent interface for declaring
  API requests.
- The `RequestProviding` protocol --- Conforming types declare the base URL of
  an API and can initialise base `Request` instances for a specific API.
- The `ResponseDecoder` structure --- A type wrapping a function that decodes a
  type from a HTTP response.
- The `BodyProvider` structure --- A type wrapping a function that encodes the
  body of a `RequestConvertible` type.

If you need to get started with _Requests_ quickly, you should investigate the
`Request` and `RequestProviding` types.

## Installation

_Requests_ supports installation using [CocoaPods][cocoapods-gh],
[Carthage][carthage-gh] or the [Swift Package Manager][swiftpm-gh]. _Requests_
supports macOS, iOS, tvOS and watchOS. Linux is not supported but may work.

> ⚠️ While _Requests_ is in the `0.x` release phase, use your package manager's
> [pessimistic operator][for-a-pessimist-im-pretty-optimistic] to pin the
> version number to a minor release.

[for-a-pessimist-im-pretty-optimistic]: https://robots.thoughtbot.com/rubys-pessimistic-operator
[cocoapods-gh]: http://cocoapods.org/
[carthage-gh]: https://github.com/carthage/carthage/
[swiftpm-gh]: https://github.com/apple/swift-package-manager

### CocoaPods

Add the following to your `Podfile`:

``` ruby
pod "Requests", "~> 0.2.0"
```

### Carthage

Add the following to your `Cartfile`:

``` ruby
github "alexjohnj/Requests" ~> 0.2.0
```

### Swift Package Manager

Add the following to your `Package.swift` file's dependencies:

``` swift
dependencies: [
    .package(url: "https://github.com/alexjohnj/Requests.git", .upToNextMinor(from: "0.2.0"))
]
```



## Create a Request Provider for an API

For each API in your application, create a type that conforms to the
`RequestProviding` protocol. These types provide the base URL for an API:

``` swift
enum ExampleAPI: RequestProviding {
    case development
    case production

    var baseURL: URL {
        switch self {
        case .development:
            return URL("https://dev.example.com/api")
        case .production:
            return URL("https://live.example.com/api")
        }
    }
}

let api = ExampleAPI.development
```

`RequestProviding` types form the entry point to building a `Request` for an
API. A `RequestProviding` type has several methods that construct a base
`Request` to an API.

## GET a Resource

To build a request to retrieve a JSON encoded resource modelled as a `Decodable`
structure, use the `get(_:from:)` method on a request provider:

``` swift
struct User: Codable { }

let getUserRequest = api.get(.json(encoded: User.self), from: "/user/1/")

URLSession.shared.perform(getUserRequest) { result in
    switch result {
    case .success(let urlResponse, let user):
        // Do something with the user
        break

    case .failed(let response?, let error):
        // We got a HTTP response but also an error. Something probably went wrong decoding the JSON.
        break

    case .failed(nil, let error):
        // We didn't get a response. There was probably a network error.
        break
    }
}
```

This method constructs a `GET` request to `https://dev.example.com/api/user/1`
and configures it with a `ResponseDecoder` that tries to decode a `User` struct
from the response's body. The returned request is generic over its response's
body's type (called the `Resource` to distinguish it from a `HTTPURLResponse`).

The `perform(_:)` method on `URLSession` performs a request and evaluates the
`ResponseDecoder` with the response's body. It then passes the decoded
`Resource` to the completion block alongside a `HTTPURLResponse` if everything
succeeds. Otherwise the block receives an `Error` and possibly a
`HTTPURLResponse`.

## POST Some Data

Sending data looks similar to retrieving a resource. To build a request that
posts a JSON encoded `User` struct, use the `post(_:to:)` method on an API's
request provider:

``` swift
let user = User()
let createUserRequest = api.post(.json(encoded: user), to: "/user/")
URLSession.shared.perform(createUserRequest) { result in
    // Handle the result
}
```

This method creates a `POST` request configured with a `BodyProvider` that
encodes the user struct as JSON. The `Resource` type of the request is `Void`
meaning the request's response doesn't have a body or the request doesn't care
about the body. Note that the `BodyProvider` will take care of updating the
request's headers to indicate the type of content it contains.

## Authenticating a Request

_Requests_ has basic support for authenticating requests. If a request can be
authenticated using its header, use an `AuthenticationProvider` to update the
header with the required credentials:

``` swift
let authToken = "DEADBEEF-DEADBEEF-DEADBEEF"
let updateUserRequest = api.patch("/user/1", with: .json(encoded: user))
    .authenticated(with: .bearerToken(authToken))

URLSession.shared.perform(updateUserRequest) { _ in }
```

This builds a `PATCH` request that will include a bearer token in the
header. _Requests_ includes built in support for attaching:

- Bearer token headers
- HTTP Basic Auth headers

You can add additional header based authentication schemes by writing a new
`AuthenticationProvider`.

## Customising Headers

The `Request` type has several functions for setting the headers of a
request. The `Header` type models a request's header, consisting of multiple
`Field`s. `Field`s consist of a name and a value.

To set the header of a request, use the `with(header:)` method:

``` swift
let getBioRequest = api.get(.text, from: "/user/1/bio")
    .with(header: [
        .acceptLanguage("en-scouse"),
        .accept(.plainText)
        ])
```

This constructs a new `Header` from an array of `Field`s and replaces the
request's header with it.

To add a header to a request or replace a single field in a request's header,
use one of `adding(headerField:)`, `adding(headerFields:)` or
`setting(headerField:)`.

> ⚠️ A request's `BodyProvider` and `AuthenticationProvider` can both modify the
> fields of a request's header. Any changes made by them will override the
> fields you specify when building the request.

## Customising Query Parameters

Similar to headers, the `Request` type provides several functions that set the
query parameters of a request:

``` swift
let searchRequest = api.get(.text, from: "/users/search")
    .with(query: [
        "query": "alex",
        "limit": "30",
        ])
```

This produces a request to the URL
`https://dev.example.com/api/users/search?query=alex&limit=30`. Note that
_Requests_ uses the Foundation `URLQueryItem` to represent query items but
provides several extensions that makes building them neater.

## Defining Custom Header Fields

_Requests_ includes several predefined fields for common HTTP headers. You can
easily add new ones by adding a `static` property on the `Field` and
`Field.Name` types:

``` swift
extension Field.Name {
    static let applicationKey = Field.Name("X-APPLICATION-KEY")
}

extension Field {
    static let applicationKey: (String) -> Field = { Field(name: .applicationKey, value: $0) }
}
```

## Defining a Base Request for an API

Some APIs require common properties set on all API requests. For example, an API
might require an application key in the header of each request. You can achieve
this by implementing an optional method in a `RequestProviding` conforming type.

The `request(to:using:)` method is the core method of the `RequestProviding`
protocol. It returns a new `Request` for an API and is the starting point for
all other request building methods on `RequestProviding`.

A custom implementation of `request(to:using:)` can return a `Request` with a
default set of values applied:

``` swift
struct ExternalAPI: RequestProviding {
    let baseURL: URL = URL("https://api.external.org")

    func request(to endpoint: String, using method: HTTPMethod) -> Request<ExternalAPI, Void> {
        return Request(api: self, endpoint: endpoint, responseDecoder: .none, method: method)
            .adding(headerField: .applicationKey("DEAD-BEEF"))
    }
}
```

Now, any `Request` built from `ExternalAPI` will include the application key header field.

## Writing a New Response Decoder

_Requests_ ships with a couple of built in `ResponseDecoder`s for JSON and text
data. It's possible to define a new `ResponseDecoder` if needed.

A `ResponseDecoder` is a structure generic over its `Response` that wraps a
throwing function taking a `HTTPURLResponse` and some `Data` and producing a
`Response`:

``` swift
public struct ResponseDecoder<Response> {

    public init(_ decode: @escaping (HTTPURLResponse, Data) throws -> Response)

    ...
}
```

When adding a new response decoder, declare a static property or function in an
extension of the `ResponseDecoder` type that returns a new
`ResponseDecoder`. This provides unqualified access to a decoder when used with
the `Request` building methods and goes a long way towards making request
definitions readable.

As an example, the definition of `.text(encoding:)` response decoder is a static
function on the `ResponseDecoder<String>` type:

``` swift
extension ResponseDecoder where Response == String {

    public static let text = ResponseDecoder<String>.text(encoding: .utf8)

    public static func text(encoding: String.Encoding) -> ResponseDecoder<String> {
        return ResponseDecoder { _, data in
            guard let string = String(data: data, encoding: encoding) else {
                throw CocoaError(.fileReadInapplicableStringEncoding,
                                 userInfo: [NSStringEncodingErrorKey: encoding.rawValue])
            }

            return string
        }
    }
}
```

Using this, the call site for the response decoder looks incredibly neat:

``` swift
let getBookRequest = api.get(.text(encoding: .ascii), from: "/book/1/contents")

// Or for UTF-8
let getOtherBookRequest = api.get(.text, from: "/book/2/contents")

```

This approach is a bit unconventional for Swift---a protocol would generally be
the more Swifty solution. However, the goal here was to optimise for readability
at the call site rather than in the implementation of the protocol. As you'll be
consuming request providers more often than you'll be writing them (especially
as _Requests_ adds more built-ins), I believe this is a worthwhile trade-off.

## Writing a New Authentication Provider

Like the `ResponseDecoder` type, an `AuthenticationProvider` is a struct
wrapping a function. An authentication provider wraps a function that mutates an
`inout Header`:

``` swift
public struct AuthenticationProvider {

    public init(authenticate: @escaping (inout Header) -> Void)

    ...
}

```

Again, declare `AuthenticationProvider`s as static properties or functions on
the `AuthenticationProvider` type so that they read nicely with the `Request`
type's methods:

``` swift
extension AuthenticationProvider {

    static let custom: (String) -> AuthenticationProvider = { customToken in
        AuthenticationProvider { header in
            header[.authorization] = "Custom \(customToken)"
        }
    }

}
```

## Writing a New Body Provider

No surprises with this one. `BodyProvider`s work the same way as
`AuthenticationProvider`s and `ResponseDecoder`s. A body provider is a struct
that wraps a throwing function that takes an `inout Header` and returns a
`RequestBody`:

``` swift
public struct BodyProvider {

    public init(encode: @escaping (inout Header) throws -> RequestBody)

    ...
}
```

In the body of the `BodyProvider` you should encode some data, update the
`ContentType` of the `Header` and then return the body. Note that the returned
`RequestBody` can wrap either raw `Data` or an `InputStream`.

Declare new body providers in static functions in an extension of `BodyProvider`:

``` swift
extension BodyProvider {
    static func text(_ text: String) -> BodyProvider {
        return BodyProvider { header in
            guard let data = text.data(using: .utf8) else {
                throw TextBodyEncodingError.utf8EncodingFailed
            }

            header.set(.contentType(.plainText))
            return .data(data)
        }
    }
}
```

> ⚠️ Only update the header of a request after calling any throwing functions.

## Advanced Usage

### The `RequestConvertible` Protocol

The `RequestConvertible` protocol is really the core of _Requests_. Indeed, for
a long time it was all there was to _Requests_. Everything else was built around
the type to simplify its usage.

`RequestConvertible` types declare all the information needed to convert a
request to a Foundation `URLRequest`. An extension method on the protocol
(`toURLRequest()`) handles the actual conversion of conforming types. If you're
building any functions that operate on requests, you should consider
constraining them to `RequestConvertible` conforming types instead of the
`Request` type itself for maximum flexibility.

Most of the properties of the `Request` type map directly to a requirement in
the `RequestConvertible` protocol. The only difference between `Request` and
`RequestConvertible` is the absence of an associated `API` type in the
protocol. `RequestConvertible` lacks this type because of the different usage
model organising requests with it opens up.

With the `RequestConvertible` protocol, you can organise you application's HTTP
requests using protocol inheritance and composition. Each request in your
application is a `RequestConvertible` type. Common properties for an API can be
declared in a protocol that inherits from the base `RequestConvertible`
protocol. This eliminates the need for an associated `API` type.

This organisation system has pros and cons. Some of the pros are:

- Ease of discoverability --- Each API request is its own type (generally in its
  own file) and so can easily be searched for in a project.
- Easy definition of ad-hoc `Resource` types --- You can satisfy the protocol's
  `Resource` associated type requirement using a type nested inside the request
  definition. This is handy for one-off responses and keeps the model of the
  request and its associated resource in close proximity.

Some of its cons:

- Boilerplate --- This approach leads to lots of boilerplate. Each API request
  needs a new type, a new file (normally) and then a protocol hiding the actual
  construction and execution of the network request.
- Protocol composition is not as composable as function composition --- If you
  try and compose two `RequestConvertible` child protocols that both have
  default implementations of the same property, you will lose the default
  implementation. You will need knowledge of the default implementations of both
  the protocols you're composing to implement the conforming type's properties
  correctly.

### Performing a Request

As has already been mentioned, _Requests_ is not concerned with performing
network requests, only constructing them. Saying that, _Requests_ does come with
a supported extension on `URLSession` to perform requests. This is there to help
people get up and running with _Requests_ but it is by no means meant to define
how _Requests_ should be used.

If you're integrating _Requests_ with another networking system, keep the
following in mind:

- Constrain your functions to operate on `RequestConvertible` types, not
  `Request`.
- A `Void` resource type indicates the request either doesn't expect or doesn't
  care about the response's body. Your functions should respect this and not
  treat a `nil` response body as an error for `Void` requests.
- `ResponseDecoders` only operate on HTTP responses. Your functions should treat
  non `HTTPURLResponse` instances as an error.
- Converting a `RequestConvertible` type to a `URLRequest` can fail.

## License

_Requests_ is released under the MIT license.
