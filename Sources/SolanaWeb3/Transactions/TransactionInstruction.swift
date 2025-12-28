//
//  TransactionInstruction.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// A TransactionInstruction object.
public struct TransactionInstruction: Codable, Equatable {
    /// Public keys to include in this transaction.
    public let keys: [AccountMeta]
    
    /// Program Id to execute
    public let programId: PublicKey
    
    /// Program input
    public let data: Data
    
    /// A TransactionInstruction object.
    public init(
        keys: [AccountMeta],
        programId: PublicKey,
        data: Data
    ) {
        self.keys = keys
        self.programId = programId
        self.data = data
    }
    
    /// Converts this TransactionInstruction into a MessageInstruction.
    public func toMessageInstruction(keys: [PublicKey]) -> MessageInstruction {
        let programIdIndex = keys.firstIndex(of: programId) ?? 0
        let accountIndices = self.keys.map { meta in
            keys.firstIndex(of: meta.pubkey) ?? 0
        }
        return MessageInstruction(
            programIdIndex: programIdIndex,
            accounts: accountIndices,
            data: Base58.encode(data)
        )
    }
}

