// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "Requests",
  products: [
    .library(name: "Requests", targets: ["Requests"])
  ],
  targets: [
    .target(name: "Requests", dependencies: [], path: "Sources/"),
    .testTarget(name: "RequestsTests", dependencies: ["Requests"], path: "Tests/")
  ]
)
