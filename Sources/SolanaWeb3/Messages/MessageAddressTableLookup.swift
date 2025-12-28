//
//  MessageAddressTableLookup.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Used by a transaction to dynamically load addresses from on-chain address lookup tables.
public struct MessageAddressTableLookup: Codable, Equatable {
    /// A base-58 encoded public key for an address lookup table account.
    public let accountKey: PublicKey
    
    /// A List of indices used to load addresses of writable accounts from a lookup table.
    public let writableIndexes: [Int]
    
    /// A list of indices used to load addresses of readonly accounts from a lookup table.
    public let readonlyIndexes: [Int]
    
    public init(
        accountKey: PublicKey,
        writableIndexes: [Int],
        readonlyIndexes: [Int]
    ) {
        self.accountKey = accountKey
        self.writableIndexes = writableIndexes
        self.readonlyIndexes = readonlyIndexes
    }
}

