//
// Created by Alex Jackson on 2018-12-23.
//

/// A media type (MIME type) used to identify content.
///
/// Media types consist of a top level `type` a `subtype` and zero or more parameters (key-value pairs). The
/// implementation in _Requests_ is based on [RFC 2045](https://tools.ietf.org/html/rfc2045#section-5) and [RFC
/// 6838](https://tools.ietf.org/html/rfc6838). The key take-aways from these RFCs are:
///
/// 1. The `type` and `subtype` of a media type are case-insensitive.
/// 2. The key of a parameter is case-insensitive but the value is case-sensitive.
/// 3. The parameters of a media type do not effect its value.
///
///
/// The implications of these for `MediaType` are:
///
/// 1. The implementations of `Equatable` and `Hashable` are case-insensitive.
/// 2. Ditto for the parameters of a `MediaType`.
/// 3. The `parameters` of a `MediaType` are not used in the `Equatable` and `Hashable` implementation of `MediaType`.
///
///
/// ## Defining New Media Types
///
/// Several common media types are defined as static properties on `MediaType`. You can add new types in an extension of
/// `MediaType`. Define the new subtype in an extension of `MediaType.SubType` and the new media type in an extension of
/// `MediaType`
///
/// For media types with required parameters (e.g., `multipart/form-data`), define the media type as a static function
/// of its required parameters. For example, `MediaType.formData` is defined as:
///
/// ```
/// static let formData: (String) -> MediaType = { boundary in
///     MediaType(type: .multipart, subtype: .formData, parameters: ["boundary": boundary])
/// }
/// ```
///
/// which will produce a new `MediaType` with the `boundary` parameter set to the provided `String`.
///
public struct MediaType: CustomStringConvertible {

    // MARK: - Nested Types

    /// A top level media type, e.g., `application`, `text`, `audio` etc.
    ///
    public struct TopLevelType: Hashable, RawRepresentable, CustomStringConvertible {

        public let rawValue: CaseInsensitiveString

        public var description: String {
            return rawValue.description
        }

        public init(rawValue: CaseInsensitiveString) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.init(rawValue: CaseInsensitiveString(rawValue))
        }
    }

    /// A sub type of a top level media type, e.g., `plain`, `css`, `json` etc.
    ///
    public struct SubType: Hashable, RawRepresentable, CustomStringConvertible {

        public let rawValue: CaseInsensitiveString

        public var description: String {
            return rawValue.description
        }

        public init(rawValue: CaseInsensitiveString) {
            self.rawValue = rawValue
        }

        public init(_ rawValue: String) {
            self.init(rawValue: CaseInsensitiveString(rawValue))
        }
    }

    // MARK: - Public Properties

    public let type: TopLevelType

    public let subtype: SubType

    public var parameters: [CaseInsensitiveString: String]

    public var rawValue: String {
        let paramComponent = parameters.map { "; \($0.key)=\($0.value)" }
        return "\(type)/\(subtype)\(paramComponent.joined())" // "type/subtype; key=value; key=value ..."
    }

    public var description: String {
        return rawValue
    }

    public init(type: TopLevelType, subtype: SubType, parameters: [CaseInsensitiveString: String] = [:]) {
        self.type = type
        self.subtype = subtype
        self.parameters = parameters
    }
}

// MARK: - Equatable Conformance

extension MediaType: Equatable {
    public static func == (lhs: MediaType, rhs: MediaType) -> Bool {
        return lhs.type == rhs.type && lhs.subtype == rhs.subtype
    }
}

// MARK: - Hashable Implementation

extension MediaType: Hashable {
    public func hash(into hasher: inout Hasher) {
        type.hash(into: &hasher)
        subtype.hash(into: &hasher)
    }
}

// MARK: - Top Level Types

public extension MediaType.TopLevelType {

    static let application = MediaType.TopLevelType("application")

    static let audio = MediaType.TopLevelType("audio")

    static let font = MediaType.TopLevelType("font")

    static let image = MediaType.TopLevelType("image")

    static let message = MediaType.TopLevelType("message")

    static let model = MediaType.TopLevelType("model")

    static let multipart = MediaType.TopLevelType("multipart")

    static let text = MediaType.TopLevelType("text")

    static let video = MediaType.TopLevelType("video")
}

// MARK: - Sub Types

public extension MediaType.SubType {

    static let plain = MediaType.SubType("plain")

    static let html = MediaType.SubType("html")

    static let css = MediaType.SubType("css")

    static let json = MediaType.SubType("json")

    static let xml = MediaType.SubType("xml")

    static let urlEncodedForm = MediaType.SubType("x-www-form-urlencoded")

    static let octetStream = MediaType.SubType("octet-stream")

    static let formData = MediaType.SubType("form-data")

    static let gif = MediaType.SubType("gif")

    static let png = MediaType.SubType("png")

    static let jpeg = MediaType.SubType("jpeg")

    static let svg = MediaType.SubType("svg+xml")
}

// MARK: - Media Types

public extension MediaType {

    // MARK: - application/*

    static let json = MediaType(type: .application, subtype: .json, parameters: ["charset": "utf-8"])

    static let xml = MediaType(type: .application, subtype: .xml, parameters: ["charset": "utf-8"])

    static let urlEncodedForm = MediaType(type: .application, subtype: .urlEncodedForm,
                                          parameters: ["charset": "utf-8"])

    static let binary = MediaType(type: .application, subtype: .octetStream)

    // MARK: - text/*

    static let plainText = MediaType(type: .text, subtype: .plain, parameters: ["charset": "utf-8"])

    static let html = MediaType(type: .text, subtype: .html, parameters: ["charset": "utf-8"])

    static let css = MediaType(type: .text, subtype: .css, parameters: ["charset": "utf-8"])

    // MARK: - image/*

    static let gif = MediaType(type: .image, subtype: .gif)

    static let png = MediaType(type: .image, subtype: .png)

    static let jpeg = MediaType(type: .image, subtype: .jpeg)

    static let svg = MediaType(type: .image, subtype: .svg)

    // MARK: - multipart/*

    /// Constructs a `multipart/form-data` media type using the given boundary.
    static let formData: (String) -> MediaType = { boundary in
        MediaType(type: .multipart, subtype: .formData, parameters: ["boundary": boundary])
    }
}
