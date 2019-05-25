# v0.2.0 (2019-05-25)

## New

- Added a `BodyProvider` type that can generate the body of a request. This
  replaces the raw body data that was previously provided by a
  `RequestConvertible` type. A `BodyProvider` wraps a throwing function that
  generates a `RequestBody` and updates a `Header`. Built-in body providers are
  included for:
  + JSON bodies
  + Plain text bodies
  + Stream bodies
  + Raw data bodies
- Added an `AuthenticationProvider` type that can add authentication credentials
  to the header of a request. An `AuthenticationProvider` wraps a function that
  updates a `Header` instance. Built-in authentication providers are included
  for:
  + HTTP Basic authentication.
  + Bearer token authentication.
- Added a setter subscript to the `Header` type that can set a `Field`.

## API Breaking Changes

- _Requests_ now requires Swift 4.2
- The `httpBody` property has been removed from the `RequestConvertible`
  protocol. It is replaced by the `bodyProvider` property. **This will silently
  break existing code**.
- Header fields are now backed by a `CaseInsensitiveString` type instead of a
  `String`.
- The `contentType` and `accept` `Field`s now accept a `MediaType` instance
  instead of a string.

# v0.1.0 (2018-12-02)

Initial release.
