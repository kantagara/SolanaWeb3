//
//  TokenProgram.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Token Program
public struct TokenProgram: Program {
    /// The program id
    public let pubkey: PublicKey
    
    /// Internal singleton instance
    private static let _instance: TokenProgram = {
        // Token Program ID: TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA
        let programId = try! PublicKey.fromString("TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")
        return TokenProgram(pubkey: programId)
    }()
    
    /// The program id
    public static var programId: PublicKey {
        return _instance.pubkey
    }
    
    /// Minimum number of multisignature signers
    public static let minSigners = 1
    
    /// Maximum number of multisignature signers
    public static let maxSigners = 11
    
    private init(pubkey: PublicKey) {
        self.pubkey = pubkey
    }

    /// SPL Token Program uses u8 instruction index (shadows the u32 default from Program)
    func createTransactionInstruction(
        instructionIndex: Int,
        keys: [AccountMeta],
        data: [Data] = []
    ) -> TransactionInstruction {
        var instructionData = Data()
        instructionData.append(Data([UInt8(instructionIndex & 0xFF)]))
        for chunk in data {
            instructionData.append(chunk)
        }
        return TransactionInstruction(
            keys: keys,
            programId: pubkey,
            data: instructionData
        )
    }

    // MARK: - Initialize Mint
    
    /// Initializes a new mint and optionally deposits all the newly minted tokens in an account.
    ///
    /// ### Keys:
    /// - `[w]` mint - The mint to initialize.
    ///
    /// ### Data:
    /// - decimals - Number of base 10 digits to the right of the decimal place.
    /// - mintAuthority - The authority/multisignature to mint tokens.
    /// - freezeAuthority - The freeze authority/multisignature of the mint (optional).
    public static func initializeMint(
        mint: PublicKey,
        decimals: UInt8,
        mintAuthority: PublicKey,
        freezeAuthority: PublicKey? = nil
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(mint),
            AccountMeta(sysvarRentPubkey)
        ]
        
        let borsh = Borsh.shared
        let data: [Data] = [
            borsh.encodeU8(decimals),
            borsh.encodePubkey(mintAuthority.toBase58()),
            borsh.encodeOptionalPubkey(freezeAuthority?.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: TokenInstruction.initializeMint.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Initialize Account
    
    /// Initializes a new account to hold tokens.
    ///
    /// ### Keys:
    /// - `[w]` account - The account to initialize.
    /// - `[]` mint - The mint this account will be associated with.
    /// - `[]` owner - The new account's owner/multisignature.
    public static func initializeAccount(
        account: PublicKey,
        mint: PublicKey,
        owner: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(account),
            AccountMeta(mint),
            AccountMeta(owner),
            AccountMeta(sysvarRentPubkey)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: TokenInstruction.initializeAccount.rawValue,
            keys: keys,
            data: []
        )
    }
    
    // MARK: - Transfer
    
    /// Transfers tokens from one account to another either directly or via a delegate.
    ///
    /// ### Keys:
    /// Single owner/delegate:
    /// - `[w]` source - The source account.
    /// - `[w]` destination - The destination account.
    /// - `[s]` owner - The source account's owner/delegate.
    ///
    /// Multisignature owner/delegate:
    /// - `[w]` source - The source account.
    /// - `[w]` destination - The destination account.
    /// - `[]` owner - The source account's multisignature owner/delegate.
    /// - `[s]` signers - The signer accounts.
    ///
    /// ### Data:
    /// - amount - The amount of tokens to transfer.
    public static func transfer(
        source: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        signers: [PublicKey] = [],
        amount: UInt64
    ) -> TransactionInstruction {
        var keys = [
            AccountMeta.writable(source),
            AccountMeta.writable(destination),
            AccountMeta(owner, isSigner: signers.isEmpty)
        ]
        
        // Add signers for multisig
        for signer in signers {
            keys.append(AccountMeta.signer(signer))
        }
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodeU64(amount)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: TokenInstruction.transfer.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Mint To
    
    /// Mints new tokens to an account.
    ///
    /// ### Keys:
    /// Single authority:
    /// - `[w]` mint - The mint.
    /// - `[w]` account - The account to mint tokens to.
    /// - `[s]` mintAuthority - The mint's minting authority.
    ///
    /// Multisignature authority:
    /// - `[w]` mint - The mint.
    /// - `[w]` account - The account to mint tokens to.
    /// - `[]` mintAuthority - The mint's multisignature mint-tokens authority.
    /// - `[s]` signers - The signer accounts.
    ///
    /// ### Data:
    /// - amount - The amount of new tokens to mint.
    public static func mintTo(
        mint: PublicKey,
        account: PublicKey,
        mintAuthority: PublicKey,
        signers: [PublicKey] = [],
        amount: UInt64
    ) -> TransactionInstruction {
        var keys = [
            AccountMeta.writable(mint),
            AccountMeta.writable(account),
            AccountMeta(mintAuthority, isSigner: signers.isEmpty)
        ]
        
        // Add signers for multisig
        for signer in signers {
            keys.append(AccountMeta.signer(signer))
        }
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodeU64(amount)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: TokenInstruction.mintTo.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Burn
    
    /// Burns tokens by removing them from an account.
    ///
    /// ### Keys:
    /// Single owner/delegate:
    /// - `[w]` account - The account to burn from.
    /// - `[w]` mint - The token mint.
    /// - `[s]` authority - The account's owner/delegate.
    ///
    /// Multisignature owner/delegate:
    /// - `[w]` account - The account to burn from.
    /// - `[w]` mint - The token mint.
    /// - `[]` authority - The account's multisignature owner/delegate.
    /// - `[s]` signers - The signer accounts.
    ///
    /// ### Data:
    /// - amount - The amount of tokens to burn.
    public static func burn(
        account: PublicKey,
        mint: PublicKey,
        authority: PublicKey,
        signers: [PublicKey] = [],
        amount: UInt64
    ) -> TransactionInstruction {
        var keys = [
            AccountMeta.writable(account),
            AccountMeta.writable(mint),
            AccountMeta(authority, isSigner: signers.isEmpty)
        ]
        
        // Add signers for multisig
        for signer in signers {
            keys.append(AccountMeta.signer(signer))
        }
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodeU64(amount)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: TokenInstruction.burn.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Close Account
    
    /// Close an account by transferring all its SOL to the destination account.
    ///
    /// ### Keys:
    /// Single owner:
    /// - `[w]` account - The account to close.
    /// - `[w]` destination - The destination account.
    /// - `[s]` owner - The account's owner.
    ///
    /// Multisignature owner:
    /// - `[w]` account - The account to close.
    /// - `[w]` destination - The destination account.
    /// - `[]` owner - The account's multisignature owner.
    /// - `[s]` signers - The signer accounts.
    public static func closeAccount(
        account: PublicKey,
        destination: PublicKey,
        owner: PublicKey,
        signers: [PublicKey] = []
    ) -> TransactionInstruction {
        var keys = [
            AccountMeta.writable(account),
            AccountMeta.writable(destination),
            AccountMeta(owner, isSigner: signers.isEmpty)
        ]
        
        // Add signers for multisig
        for signer in signers {
            keys.append(AccountMeta.signer(signer))
        }
        
        return _instance.createTransactionInstruction(
            instructionIndex: TokenInstruction.closeAccount.rawValue,
            keys: keys,
            data: []
        )
    }
}

