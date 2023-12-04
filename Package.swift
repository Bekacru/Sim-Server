// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Sim",
  products: [
    .library(
      name: "Sim",
      targets: ["Sim"])
  ],
  targets: [
    .target(
      name: "Sim"),
    .testTarget(
      name: "SimTests",
      dependencies: ["Sim"]),
  ]
)
