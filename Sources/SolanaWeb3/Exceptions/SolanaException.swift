//
//  SolanaException.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Base exception class for Solana errors
public class SolanaException: Error, CustomStringConvertible {
    public let message: String
    public let code: Int?
    
    public init(_ message: String, code: Int? = nil) {
        self.message = message
        self.code = code
    }
    
    public var description: String {
        if let code = code {
            return "SolanaException(code: \(code), message: \(message))"
        }
        return "SolanaException(message: \(message))"
    }
    
    public var localizedDescription: String {
        return message
    }
}

