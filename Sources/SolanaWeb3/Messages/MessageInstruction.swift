//
//  MessageInstruction.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// An instruction to execute by a program.
public struct MessageInstruction: Codable, Equatable {
    /// Index into the Message.accountKeys array indicating the program account that executes this instruction.
    public let programIdIndex: Int
    
    /// List of ordered indices into the message.accountKeys array indicating which accounts to pass to the program.
    public let accounts: [Int]
    
    /// The program's input data encoded as a base-58 string.
    public let data: String
    
    public init(
        programIdIndex: Int,
        accounts: [Int],
        data: String
    ) {
        self.programIdIndex = programIdIndex
        self.accounts = accounts
        self.data = data
    }
}

