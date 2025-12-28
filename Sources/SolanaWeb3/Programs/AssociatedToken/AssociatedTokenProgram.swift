//
//  AssociatedTokenProgram.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Associated Token Program
public struct AssociatedTokenProgram: Program {
    /// The program id
    public let pubkey: PublicKey
    
    /// Internal singleton instance
    private static let _instance: AssociatedTokenProgram = {
        // Associated Token Program ID: ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL
        let programId = try! PublicKey.fromString("ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")
        return AssociatedTokenProgram(pubkey: programId)
    }()
    
    /// The program id
    public static var programId: PublicKey {
        return _instance.pubkey
    }
    
    private init(pubkey: PublicKey) {
        self.pubkey = pubkey
    }
    
    // MARK: - Create
    
    /// Creates an associated token account for the given wallet address and token mint.
    ///
    /// Returns an error if the account exists.
    ///
    /// ### Keys:
    /// - `[w,s]` fundingAccount - Funding account (must be a system account).
    /// - `[w]` associatedTokenAccount - Associated token account address to be created.
    /// - `[]` associatedTokenAccountOwner - Wallet address for the new associated token account.
    /// - `[]` tokenMint - The token mint for the new associated token account.
    public static func create(
        fundingAccount: PublicKey,
        associatedTokenAccount: PublicKey,
        associatedTokenAccountOwner: PublicKey,
        tokenMint: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.signerAndWritable(fundingAccount),
            AccountMeta.writable(associatedTokenAccount),
            AccountMeta(associatedTokenAccountOwner),
            AccountMeta(tokenMint),
            AccountMeta(SystemProgram.programId),
            AccountMeta(TokenProgram.programId)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: AssociatedTokenInstruction.create.rawValue,
            keys: keys,
            data: []
        )
    }
    
    // MARK: - Create Idempotent
    
    /// Creates an associated token account for the given wallet address and token mint, if it doesn't
    /// already exist. Returns an error if the account exists, but with a different owner.
    ///
    /// ### Keys:
    /// - `[w,s]` fundingAccount - Funding account (must be a system account).
    /// - `[w]` associatedTokenAccount - Associated token account address to be created.
    /// - `[]` associatedTokenAccountOwner - Wallet address for the new associated token account.
    /// - `[]` tokenMint - The token mint for the new associated token account.
    public static func createIdempotent(
        fundingAccount: PublicKey,
        associatedTokenAccount: PublicKey,
        associatedTokenAccountOwner: PublicKey,
        tokenMint: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.signerAndWritable(fundingAccount),
            AccountMeta.writable(associatedTokenAccount),
            AccountMeta(associatedTokenAccountOwner),
            AccountMeta(tokenMint),
            AccountMeta(SystemProgram.programId),
            AccountMeta(TokenProgram.programId)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: AssociatedTokenInstruction.createIdempotent.rawValue,
            keys: keys,
            data: []
        )
    }
}

