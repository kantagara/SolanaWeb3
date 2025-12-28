//
//  Program.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Program base class
public protocol Program {
    /// The public key that identifies this program (i.e. program id).
    var pubkey: PublicKey { get }
}

/// Program helper methods
public extension Program {
    /// Encodes the program instruction index as u32 (little-endian)
    func encodeInstruction(_ instructionIndex: Int) -> Data {
        var bytes = Data(count: 4)
        let index = UInt32(instructionIndex)
        bytes[0] = UInt8(index & 0xFF)
        bytes[1] = UInt8((index >> 8) & 0xFF)
        bytes[2] = UInt8((index >> 16) & 0xFF)
        bytes[3] = UInt8((index >> 24) & 0xFF)
        return bytes
    }
    
    /// Creates a TransactionInstruction for the program instruction
    func createTransactionInstruction(
        instructionIndex: Int,
        keys: [AccountMeta],
        data: [Data] = []
    ) -> TransactionInstruction {
        var instructionData = Data()
        // Write instruction index as u32
        instructionData.append(encodeInstruction(instructionIndex))
        // Append all data chunks
        for chunk in data {
            instructionData.append(chunk)
        }
        return TransactionInstruction(
            keys: keys,
            programId: pubkey,
            data: instructionData
        )
    }
}

