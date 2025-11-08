// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

//let otPackages = "https://github.com/DataDog/opentelemetry-swift-packages.git"
//let otPackagesID  = "opentelemetry-swift-packages"

let package = Package(
  name: "opentelemetry-swift-core",
  platforms: [
    .macOS(.v10_13),
    .iOS(.v12),
    .tvOS(.v12),
    .watchOS(.v4),
    .visionOS(.v1),
  ],
  products: [
//    .library(name: "OpenTelemetryApi", targets: ["OpenTelemetryApi"]),
    .library(name: "OpenTelemetryConcurrency", targets: ["OpenTelemetryConcurrency"]),
    .library(name: "OpenTelemetrySdk", targets: ["OpenTelemetrySdk"]),
    .library(name: "StdoutExporter", targets: ["StdoutExporter"]),
    .executable(name: "ConcurrencyContext", targets: ["ConcurrencyContext"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-atomics.git", from: "1.3.0"),
//    .package(
//        url: otPackages, exact: Version(stringLiteral: "1.13.1")
//    ),
  ],
  targets: [
//    .target(
//      name: "OpenTelemetryApi",
//      dependencies: []
//    ),
    .target(
        name: "OpenTelemetryApi137",             // <- unique target/module
        path: "Sources/OpenTelemetryApi"
    ),
    .target(
      name: "OpenTelemetrySdk",
      dependencies: [
        "OpenTelemetryApi137",
        .product(name: "Atomics", package: "swift-atomics", condition: .when(platforms: [.linux])),
      ],
      swiftSettings: [
        .unsafeFlags([
            "-Xfrontend", "-module-alias",
            "-Xfrontend", "OpenTelemetryApi=OpenTelemetryApi137"
          ])
      ]
    ),
    .target(
      name: "OpenTelemetryConcurrency",
      dependencies: [
        "OpenTelemetryApi137"
      ],
      swiftSettings: [
        .unsafeFlags([
            "-Xfrontend", "-module-alias",
            "-Xfrontend", "OpenTelemetryApi=OpenTelemetryApi137"
          ])
      ]
    ),
    .target(
      name: "StdoutExporter",
      dependencies: ["OpenTelemetrySdk"],
      path: "Sources/Exporters/Stdout"
    ),
    .target(
      name: "OpenTelemetryTestUtils",
      dependencies: [
        "OpenTelemetrySdk",
        "OpenTelemetryApi137"
      ],
      swiftSettings: [
        .unsafeFlags([
            "-Xfrontend", "-module-alias",
            "-Xfrontend", "OpenTelemetryApi=OpenTelemetryApi137"
          ])
      ]
    ),
    .testTarget(
      name: "OpenTelemetryApiTests",
      dependencies: [
        "OpenTelemetryTestUtils",
        "OpenTelemetryApi137"
      ],
      path: "Tests/OpenTelemetryApiTests",
      swiftSettings: [
        .unsafeFlags([
            "-Xfrontend", "-module-alias",
            "-Xfrontend", "OpenTelemetryApi=OpenTelemetryApi137"
          ])
      ]
    ),
    .testTarget(
      name: "OpenTelemetrySdkTests",
      dependencies: [
        "OpenTelemetrySdk",
        "OpenTelemetryConcurrency",
        "OpenTelemetryTestUtils",
      ],
      path: "Tests/OpenTelemetrySdkTests"
    ),
    .executableTarget(
      name: "ConcurrencyContext",
      dependencies: ["OpenTelemetrySdk", "OpenTelemetryConcurrency", "StdoutExporter"],
      path: "Examples/ConcurrencyContext"
    ),
  ]
)

if ProcessInfo.processInfo.environment["OTEL_ENABLE_SWIFTLINT"] != nil {
  package.dependencies.append(contentsOf: [
    .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.57.1")
  ])

  for target in package.targets {
    target.plugins = [
      .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")
    ]
  }
}
