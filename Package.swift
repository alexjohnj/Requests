// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "Requests",
  products: [
    .library(name: "Requests", targets: ["Requests"])
  ],
  targets: [
    .target(name: "Requests", dependencies: []),
    .testTarget(name: "RequestsTests", dependencies: ["Requests"])
  ]
)
