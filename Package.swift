// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

// Copyright 2022 Manuel M T Chakravarty
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PackageDescription

let package = Package(
  name: "ProjectNavigator",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
    .visionOS(.v1)
  ],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "Files",
      targets: ["Files"]),
    .library(
      name: "ProjectNavigator",
      targets: ["ProjectNavigator"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/apple/swift-collections.git",
      .upToNextMajor(from: "1.0.0")),
    .package(
      url: "https://github.com/apple/swift-docc-plugin",
      from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "Files",
      dependencies: [.product(name: "OrderedCollections", package: "swift-collections")]),
    .target(
      name: "_FilesTestSupport",
      dependencies: ["Files"]),
    .testTarget(
      name: "FilesTests",
      dependencies: ["Files", "_FilesTestSupport"]),
    .target(
      name: "ProjectNavigator",
      dependencies: [
        "Files",
        "_FilesTestSupport",
        .product(name: "OrderedCollections", package: "swift-collections")]),
    .testTarget(
      name: "ProjectNavigatorTests",
      dependencies: ["ProjectNavigator"]),
  ]
)
