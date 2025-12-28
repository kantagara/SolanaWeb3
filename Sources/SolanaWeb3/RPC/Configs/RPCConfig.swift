//
//  RPCConfig.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Base RPC Config with Commitment and MinContextSlot
public struct CommitmentAndMinContextSlotConfig: Codable, Equatable {
    public let commitment: Commitment?
    public let minContextSlot: UInt64?
    
    public init(commitment: Commitment? = nil, minContextSlot: UInt64? = nil) {
        self.commitment = commitment
        self.minContextSlot = minContextSlot
    }
}

/// Get Latest Blockhash Config
public typealias GetLatestBlockhashConfig = CommitmentAndMinContextSlotConfig

/// Get Balance Config
public typealias GetBalanceConfig = CommitmentAndMinContextSlotConfig

/// Get Account Info Config
public struct GetAccountInfoConfig: Codable, Equatable {
    public let commitment: Commitment?
    public let encoding: AccountEncoding?
    public let dataSlice: DataSlice?
    public let minContextSlot: UInt64?
    
    public init(
        commitment: Commitment? = nil,
        encoding: AccountEncoding? = nil,
        dataSlice: DataSlice? = nil,
        minContextSlot: UInt64? = nil
    ) {
        self.commitment = commitment
        self.encoding = encoding
        self.dataSlice = dataSlice
        self.minContextSlot = minContextSlot
    }
}

/// Data Slice
public struct DataSlice: Codable, Equatable {
    public let offset: Int
    public let length: Int
    
    public init(offset: Int, length: Int) {
        self.offset = offset
        self.length = length
    }
}

/// Send Transaction Config
public struct SendTransactionConfig: Codable, Equatable {
    public let skipPreflight: Bool?
    public let preflightCommitment: Commitment?
    public let maxRetries: UInt?
    public let minContextSlot: UInt64?
    
    public init(
        skipPreflight: Bool? = nil,
        preflightCommitment: Commitment? = nil,
        maxRetries: UInt? = nil,
        minContextSlot: UInt64? = nil
    ) {
        self.skipPreflight = skipPreflight
        self.preflightCommitment = preflightCommitment
        self.maxRetries = maxRetries
        self.minContextSlot = minContextSlot
    }
}

/// Get Block Height Config
public typealias GetBlockHeightConfig = CommitmentAndMinContextSlotConfig

