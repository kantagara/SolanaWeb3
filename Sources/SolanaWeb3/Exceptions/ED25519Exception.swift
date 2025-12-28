//
//  ED25519Exception.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Exception for ed25519 public key signature system
public class ED25519Exception: SolanaException {
    public override init(_ message: String, code: Int? = nil) {
        super.init(message, code: code)
    }
}

