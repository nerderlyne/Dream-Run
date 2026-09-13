// swift-tools-version: 6.0
import PackageDescription
let package = Package(name: "DreamCore", platforms: [.macOS(.v13), .iOS(.v18)], products: [.library(name: "DreamCore", targets: ["DreamCore"])], targets: [.target(name: "DreamCore", path: "Dream Again/Core"), .testTarget(name: "DreamCoreTests", dependencies: ["DreamCore"], path: "Tests/DreamCoreTests", resources: [.copy("conformance_vectors.json")])])
