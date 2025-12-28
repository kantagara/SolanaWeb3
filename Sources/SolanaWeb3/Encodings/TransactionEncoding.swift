//
//  TransactionEncoding.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Transaction Encodings
public enum TransactionEncoding: String, Codable {
    case base58
    case base64
    case json
    case jsonParsed
}

