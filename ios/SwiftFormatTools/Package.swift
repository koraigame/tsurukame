// swift-tools-version:4.0
import PackageDescription

let package = Package(name: "SwiftFormatTools",
                      dependencies: [
                         .package(url: "https://github.com/nicklockwood/SwiftFormat",
                                  .upToNextMinor(from: "0.47.12")),
                      ],
                      targets: [.target(name: "SwiftFormatTools", path: "")])
