// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ax-editor",
    products: [
         .executable(name: "ax", targets: ["ax-editor"])
     ],
    
    dependencies: [
         .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
    ],
    
    targets: [
        .target(
            name: "Core",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]),
        .target(
            name: "ax-editor",
            dependencies: ["Core"]
        ),
        .testTarget(
            name: "ax-editorTests",
            dependencies: ["ax-editor"]),
    ]
)
