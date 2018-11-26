# Requests

A Swift library with some sugar for building and organising HTTP requests.

## API Stability

The API for the library is still a little in flux so I'd avoid adopting it for
the time being. I'm currently working on a new `Request` builder type on the
`wip/radical-new-idea` branch and it will change the API in a significant
way. The changes I anticipate are:

- Renaming the `Request` protocol to something else (the protocol will remain
  however).
- Renaming some of the built in `ResponseDecoder` instances.

More long term I also plan to change how specifying the body for a request
works. Right now the body is just raw data but in the future I want to implement
a type similar to `ResponseDecoder` that handles encoding a body and updating
the request's headers.

In terms of actual stability, I've used this library in one form or another in
several apps now without any problems. There's unit tests for _almost_
everything and, to be honest, in its current form the library doesn't do
anything particularly complex. Exercise caution as you would for any other
library.

## Basic Usage

_Complete documentation coming real soon. There's quite a lot of documentation
comments in the actual source._

The core of the library is the `Request` protocol which describes all the
components of a request and the request's associated resource. To build an API
request, create a new type that conforms to it and implements the required
properties. You can use protocol inheritance to provide sensible defaults for
your API:

``` swift
struct Pokemon: Decodable {
    let id: Int
    let name: String
}

protocol PokemonRequest: Request { }

extension PokemonRequest {
    var baseURL: URL {
        return URL("https://pokeapi.co/api/v2")
    }
}

/// A request to retrieve a Pokemon by name.
struct GetPokemenRequest: PokemonRequest {

    typealias Resource = Pokemon

    let pokemonName: String

    var method: HTTPMethod {
        return .get
    }

    var endpoint: String {
        return "/pokemon/\(pokemonName)"
    }

    // Converts the raw response data into a `Resource`.
    var responseDecoder: ResponseDecoder<Pokemon> {
        return .json()
    }
}

/// A request to retrieve a move's raw JSON text by ID.
struct GetMoveRequest: PokemonRequest {

    // No need to specify an explicit response decoder for this type.
    typealias Resource = String

    let moveNumber: Int

    var method: HTTPMethod {
        return .get
    }

    var endpoint: String {
        return "/move/\(moveNumber)"
    }
}

URLSession.shared.perform(GetPokemenRequest(pokemonName: "eevee")) { (result: Result<Pokemon>) in
    switch result {
    case .success(let response, let pokemon):
        print(response.statusCode)
        print(pokemon)
    case .failed(.some(let response), let error):
        // A response and an error suggests there was an error decoding the response body.
        print(response.statusCode)
        print(error)
    case .failed(nil, let error):
        // No response and an error indicates something went wrong client side.
        print(error)
    }
}
```

## Installation

Currently the only supported installation method is with
[Carthage][carthage-gh]. I will add CocoaPods and Swift Package Manager support
as the library approaches an initial release.

[carthage-gh]: https://github.com/carthage/carthage/
