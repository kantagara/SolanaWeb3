//
//  AccountMeta.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Account metadata used to define instruction accounts.
public struct AccountMeta: Codable, Equatable {
    /// An account's public key.
    public let pubkey: PublicKey
    
    /// True if an instruction requires a transaction signature matching pubkey.
    public let isSigner: Bool
    
    /// True if the pubkey can be loaded as a read-write account.
    public let isWritable: Bool
    
    /// Account metadata used to define instruction accounts.
    public init(
        _ pubkey: PublicKey,
        isSigner: Bool = false,
        isWritable: Bool = false
    ) {
        self.pubkey = pubkey
        self.isSigner = isSigner
        self.isWritable = isWritable
    }
    
    /// Creates a signer account.
    public static func signer(_ pubkey: PublicKey, isWritable: Bool = false) -> AccountMeta {
        return AccountMeta(pubkey, isSigner: true, isWritable: isWritable)
    }
    
    /// Creates a writable account.
    public static func writable(_ pubkey: PublicKey, isSigner: Bool = false) -> AccountMeta {
        return AccountMeta(pubkey, isSigner: isSigner, isWritable: true)
    }
    
    /// Creates a signer and writable account.
    public static func signerAndWritable(_ pubkey: PublicKey) -> AccountMeta {
        return AccountMeta(pubkey, isSigner: true, isWritable: true)
    }
    
    /// Creates a copy of this struct applying the provided parameters to the new instance.
    public func copyWith(
        pubkey: PublicKey? = nil,
        isSigner: Bool? = nil,
        isWritable: Bool? = nil
    ) -> AccountMeta {
        return AccountMeta(
            pubkey ?? self.pubkey,
            isSigner: isSigner ?? self.isSigner,
            isWritable: isWritable ?? self.isWritable
        )
    }
}

