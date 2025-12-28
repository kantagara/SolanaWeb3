// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SolanaWeb3",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "SolanaWeb3",
            targets: ["SolanaWeb3"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/metaplex-foundation/beet-swift", from: "1.0.0"),
        .package(url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap", from: "1.1.0"),
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),
    ],
    targets: [
        .target(
            name: "SolanaWeb3",
            dependencies: [
                .product(name: "Beet", package: "beet-swift"),
                .product(name: "TweetNacl", package: "tweetnacl-swiftwrap"),
                .product(name: "AnyCodable", package: "AnyCodable"),
            ]
        ),
        .testTarget(
            name: "SolanaWeb3Tests",
            dependencies: ["SolanaWeb3"]
        ),
    ]
)

