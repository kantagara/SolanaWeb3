//
//  TransactionException.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Exception for invalid transaction
public class TransactionException: SolanaException {
    public override init(_ message: String, code: Int? = nil) {
        super.init(message, code: code)
    }
}

/// Exception for transaction signature
public class TransactionSignatureException: SolanaException {
    public override init(_ message: String, code: Int? = nil) {
        super.init(message, code: code)
    }
}

