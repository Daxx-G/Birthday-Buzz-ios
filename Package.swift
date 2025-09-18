// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BirthdayBuzz",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "BirthdayBuzz",
            targets: ["BirthdayBuzz"]
        ),
    ],
    dependencies: [
        // TODO: Add any external dependencies here
        // Example: .package(url: "https://github.com/example/SomePackage.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "BirthdayBuzz",
            dependencies: [],
            path: ".",
            exclude: [
                "Tests/",
                "README.md",
                "PLANNING.md",
                ".git/",
                ".gitignore"
            ]
        ),
        .testTarget(
            name: "BirthdayBuzzTests",
            dependencies: ["BirthdayBuzz"],
            path: "Tests"
        ),
    ]
)
