//
//  PublicKeyException.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Exception for invalid public key
public class PublicKeyException: SolanaException {
    public override init(_ message: String, code: Int? = nil) {
        super.init(message, code: code)
    }
    
    /// Creates an exception for an invalid public key length.
    public static func invalidLength(_ length: Int, maxLength: Int = 32) -> PublicKeyException {
        return PublicKeyException("Invalid public key length of \(length), expected \(maxLength).")
    }
}

