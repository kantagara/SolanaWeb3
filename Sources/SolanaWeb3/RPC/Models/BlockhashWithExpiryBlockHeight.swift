//
//  BlockhashWithExpiryBlockHeight.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Blockhash With Expiry Block Height
public struct BlockhashWithExpiryBlockHeight: Codable, Equatable {
    /// A unique base-58 encoded hash that identifies a record (block).
    public let blockhash: Blockhash
    
    /// The last block height at which the blockhash will be valid.
    public let lastValidBlockHeight: UInt64
    
    public init(blockhash: Blockhash, lastValidBlockHeight: UInt64) {
        self.blockhash = blockhash
        self.lastValidBlockHeight = lastValidBlockHeight
    }
}

