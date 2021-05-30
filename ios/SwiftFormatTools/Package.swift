// swift-tools-version:4.0
import PackageDescription

let package = Package(name: "SwiftFormatTools",
                      dependencies: [
                        .package(url: "https://github.com/nicklockwood/SwiftFormat",
                                 .exact("0.37.2")),
                      ],
                      targets: [.target(name: "SwiftFormatTools", path: "")])
