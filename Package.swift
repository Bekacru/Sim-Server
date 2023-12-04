// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Sim",
  products: [
    .library(
      name: "Sim",
      targets: ["Sim"]),
    .executable(name: "Example", targets: ["Example"]),
  ],
  targets: [
    .target(
      name: "Sim"),
    .executableTarget(name: "Example", dependencies: ["Sim"]),
    .testTarget(
      name: "SimTests",
      dependencies: ["Sim"]),
  ]
)
