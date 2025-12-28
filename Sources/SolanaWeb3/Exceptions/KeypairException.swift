//
//  KeypairException.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Exception for invalid keypair
public class KeypairException: SolanaException {
    public override init(_ message: String, code: Int? = nil) {
        super.init(message, code: code)
    }
}

