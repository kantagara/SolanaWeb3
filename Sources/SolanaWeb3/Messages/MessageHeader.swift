//
//  MessageHeader.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Details the account types and signatures required by the transaction (signed and read-only accounts).
public struct MessageHeader: Codable, Equatable {
    /// The total number of signatures required to make the transaction valid.
    public let numRequiredSignatures: Int
    
    /// The last numReadonlySignedAccounts of the signed keys are read-only accounts.
    public let numReadonlySignedAccounts: Int
    
    /// The last numReadonlyUnsignedAccounts of the unsigned keys are read-only accounts.
    public let numReadonlyUnsignedAccounts: Int
    
    public init(
        numRequiredSignatures: Int,
        numReadonlySignedAccounts: Int,
        numReadonlyUnsignedAccounts: Int
    ) {
        self.numRequiredSignatures = numRequiredSignatures
        self.numReadonlySignedAccounts = numReadonlySignedAccounts
        self.numReadonlyUnsignedAccounts = numReadonlyUnsignedAccounts
    }
}

