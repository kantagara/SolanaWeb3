//
//  SystemProgram.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// System Program
public struct SystemProgram: Program {
    /// The program id (System Program is always the zero pubkey)
    public let pubkey: PublicKey
    
    /// Internal singleton instance
    private static let _instance = SystemProgram(pubkey: PublicKey.zero())
    
    /// The program id
    public static var programId: PublicKey {
        return _instance.pubkey
    }
    
    private init(pubkey: PublicKey) {
        self.pubkey = pubkey
    }
    
    // MARK: - Create Account
    
    /// Generates a transaction instruction that creates a new account.
    ///
    /// ### Keys:
    /// - `[w,s]` fromPubkey - The account that will transfer lamports to the created account.
    /// - `[w,s]` newAccountPubkey - The public key of the created account.
    ///
    /// ### Data:
    /// - lamports - The amount of lamports to transfer to the created account.
    /// - space - The amount of space in bytes to allocate to the created account.
    /// - programId - The public key of the program to assign as the owner of the created account.
    public static func createAccount(
        fromPubkey: PublicKey,
        newAccountPubkey: PublicKey,
        lamports: UInt64,
        space: UInt64,
        programId: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.signerAndWritable(fromPubkey),
            AccountMeta.signerAndWritable(newAccountPubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodeU64(lamports),
            borsh.encodeU64(space),
            borsh.encodePubkey(programId.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.create.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Transfer
    
    /// Generates a transaction instruction that transfers lamports from one account to another.
    ///
    /// ### Keys:
    /// - fromPubkey - The account that will transfer lamports.
    /// - toPubkey - The account that will receive transferred lamports.
    ///
    /// ### Data:
    /// - lamports - The amount of lamports to transfer.
    public static func transfer(
        fromPubkey: PublicKey,
        toPubkey: PublicKey,
        lamports: UInt64
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.signerAndWritable(fromPubkey),
            AccountMeta.writable(toPubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodeU64(lamports)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.transfer.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Transfer With Seed
    
    /// Generates a transaction instruction that transfers lamports from one account to another.
    ///
    /// ### Keys:
    /// - fromPubkey - The account that will transfer lamports.
    /// - basePubkey - The base public key used to derive the funding account address.
    /// - toPubkey - The account that will receive the transferred lamports.
    ///
    /// ### Data:
    /// - lamports - The amount of lamports to transfer.
    /// - seed - The seed used to derive the funding account address.
    /// - programId - The program id used to derive the funding account address.
    public static func transferWithSeed(
        fromPubkey: PublicKey,
        basePubkey: PublicKey,
        toPubkey: PublicKey,
        lamports: UInt64,
        seed: String,
        programId: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(fromPubkey),
            AccountMeta.signer(basePubkey),
            AccountMeta.writable(toPubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodeU64(lamports),
            borsh.encodeRustString(seed),
            borsh.encodePubkey(programId.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.transferWithSeed.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Assign
    
    /// Generates a transaction instruction that assigns an account to a program.
    ///
    /// ### Keys:
    /// - accountPubkey - The public key of the account which will be assigned a new owner.
    ///
    /// ### Data:
    /// - programId - The public key of the program to assign as the owner.
    public static func assign(
        accountPubkey: PublicKey,
        programId: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.signerAndWritable(accountPubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodePubkey(programId.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.assign.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Assign With Seed
    
    /// Generates a transaction instruction that assigns an account to a program.
    ///
    /// ### Keys:
    /// - accountPubkey - The public key of the account which will be assigned a new owner.
    ///
    /// ### Data:
    /// - basePubkey - The base public key used to derive the address of the assigned account.
    /// - seed - The seed used to derive the address of the assigned account.
    /// - programId - The public key of the program to assign as the owner.
    public static func assignWithSeed(
        accountPubkey: PublicKey,
        basePubkey: PublicKey,
        seed: String,
        programId: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(accountPubkey),
            AccountMeta.signer(basePubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodePubkey(basePubkey.toBase58()),
            borsh.encodeRustString(seed),
            borsh.encodePubkey(programId.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.assignWithSeed.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Create Account With Seed
    
    /// Creates a transaction instruction that creates a new account at an address generated with
    /// `fromPubkey`, a `seed`, and `programId`.
    ///
    /// ### Keys:
    /// - fromPubkey - The account that will transfer lamports to the created account.
    /// - newAccountPubkey - The public key of the created account. Must be pre-calculated with
    ///   PublicKey.createWithSeed().
    ///
    /// ### Data:
    /// - basePubkey - The base public key used to derive the address of the created account.
    /// - seed - The seed used to derive the address of the created account.
    /// - lamports - The amount of lamports to transfer to the created account.
    /// - space - The amount of space in bytes to allocate to the created account.
    /// - programId - The public key of the program to assign as the owner of the created account.
    public static func createAccountWithSeed(
        fromPubkey: PublicKey,
        newAccountPubkey: PublicKey,
        basePubkey: PublicKey,
        seed: String,
        lamports: UInt64,
        space: UInt64,
        programId: PublicKey
    ) -> TransactionInstruction {
        var keys = [
            AccountMeta.signerAndWritable(fromPubkey),
            AccountMeta.writable(newAccountPubkey)
        ]
        
        // Add basePubkey as signer if different from fromPubkey
        if fromPubkey != basePubkey {
            keys.append(AccountMeta.signer(basePubkey))
        }
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodePubkey(basePubkey.toBase58()),
            borsh.encodeRustString(seed),
            borsh.encodeU64(lamports),
            borsh.encodeU64(space),
            borsh.encodePubkey(programId.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.createWithSeed.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Allocate
    
    /// Generates a transaction instruction that allocates space in an account without funding.
    ///
    /// ### Keys:
    /// - `[s, w]` accountPubkey - The public key of the account which will be assigned a new owner.
    ///
    /// ### Data:
    /// - space - The amount of space in bytes to allocate.
    public static func allocate(
        accountPubkey: PublicKey,
        space: UInt64
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.signerAndWritable(accountPubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodeU64(space)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.allocate.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Allocate With Seed
    
    /// Generates a transaction instruction that allocates space in an account without funding.
    ///
    /// ### Keys:
    /// - `[w]` accountPubkey - The public key of the account which will be assigned a new owner.
    /// - `[s]` basePubkey - The base public key used to derive the address of the assigned account.
    ///
    /// ### Data:
    /// - basePubkey - The base public key used to derive the address of the assigned account.
    /// - seed - The seed used to derive the address of the assigned account.
    /// - space - The amount of space in bytes to allocate.
    /// - programId - The public key of the program to assign as the owner.
    public static func allocateWithSeed(
        accountPubkey: PublicKey,
        basePubkey: PublicKey,
        seed: String,
        space: UInt64,
        programId: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(accountPubkey),
            AccountMeta.signer(basePubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodePubkey(basePubkey.toBase58()),
            borsh.encodeRustString(seed),
            borsh.encodeU64(space),
            borsh.encodePubkey(programId.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.allocateWithSeed.rawValue,
            keys: keys,
            data: data
        )
    }
    
    // MARK: - Nonce Account Methods
    
    /// Generates an instruction to initialize a Nonce account.
    ///
    /// ### Keys:
    /// - `[w]` noncePubkey - The nonce account.
    ///
    /// ### Data:
    /// - authorizedPubkey - The public key of the nonce authority.
    public static func nonceInitialize(
        noncePubkey: PublicKey,
        authorizedPubkey: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(noncePubkey),
            AccountMeta(sysvarRecentBlockhashesPubkey),
            AccountMeta(sysvarRentPubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodePubkey(authorizedPubkey.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.initializeNonceAccount.rawValue,
            keys: keys,
            data: data
        )
    }
    
    /// Generates an instruction to advance the nonce in a Nonce account.
    ///
    /// ### Keys:
    /// - `[w]` noncePubkey - The nonce account.
    /// - `[s]` authorizedPubkey - The public key of the nonce authority.
    public static func nonceAdvance(
        noncePubkey: PublicKey,
        authorizedPubkey: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(noncePubkey),
            AccountMeta(sysvarRecentBlockhashesPubkey),
            AccountMeta.signer(authorizedPubkey)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.advanceNonceAccount.rawValue,
            keys: keys,
            data: []
        )
    }
    
    /// Generates a transaction instruction that withdraws lamports from a Nonce account.
    ///
    /// ### Keys:
    /// - `[w]` noncePubkey - The nonce account.
    /// - `[s]` authorizedPubkey - The public key of the nonce authority.
    /// - `[w]` toPubkey - The public key of the account which will receive the withdrawn nonce
    ///   account balance.
    ///
    /// ### Data:
    /// - lamports - The amount of lamports to withdraw from the nonce account.
    public static func nonceWithdraw(
        noncePubkey: PublicKey,
        authorizedPubkey: PublicKey,
        toPubkey: PublicKey,
        lamports: UInt64
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(noncePubkey),
            AccountMeta.writable(toPubkey),
            AccountMeta(sysvarRecentBlockhashesPubkey),
            AccountMeta(sysvarRentPubkey),
            AccountMeta.signer(authorizedPubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodeU64(lamports)
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.withdrawNonceAccount.rawValue,
            keys: keys,
            data: data
        )
    }
    
    /// Generates a transaction instruction that authorises a new Pubkey as the authority on a
    /// Nonce account.
    ///
    /// ### Keys:
    /// - `[w]` noncePubkey - The nonce account.
    /// - `[s]` authorizedPubkey - The public key of the current nonce authority.
    ///
    /// ### Data:
    /// - newAuthorizedPubkey - The public key to set as the new nonce authority.
    public static func nonceAuthorize(
        noncePubkey: PublicKey,
        authorizedPubkey: PublicKey,
        newAuthorizedPubkey: PublicKey
    ) -> TransactionInstruction {
        let keys = [
            AccountMeta.writable(noncePubkey),
            AccountMeta.signer(authorizedPubkey)
        ]
        
        let borsh = Borsh.shared
        let data = [
            borsh.encodePubkey(newAuthorizedPubkey.toBase58())
        ]
        
        return _instance.createTransactionInstruction(
            instructionIndex: SystemInstruction.authorizeNonceAccount.rawValue,
            keys: keys,
            data: data
        )
    }
}

