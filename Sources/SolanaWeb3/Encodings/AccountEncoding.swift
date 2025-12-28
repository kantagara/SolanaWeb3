//
//  AccountEncoding.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Account Encodings
public enum AccountEncoding: String, Codable {
    case base58 = "base58"
    case base64 = "base64"
    case base64Zstd = "base64+zstd"
    case jsonParsed = "jsonParsed"
    
    /// If true, the value is valid for encoding binary data (`base58`, `base64` or `base64Zstd`).
    public var isBinary: Bool {
        return self == .base58 || self == .base64 || self == .base64Zstd
    }
    
    /// If true, the value is valid for encoding JSON data (`json` or `jsonParsed`).
    public var isJson: Bool {
        return self == .jsonParsed
    }
}

