//
//  Keypair.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Signer protocol
public protocol Signer {
    /// The keypair's public key.
    var pubkey: PublicKey { get }
    
    /// The keypair's secret key.
    var seckey: Data { get }
}

/// Keypair
public struct Keypair: Signer {
    /// The public key and secret key pair.
    private let keypair: Ed25519Keypair
    
    /// The public key for this keypair.
    public var pubkey: PublicKey {
        do {
            return try PublicKey.fromBytes(keypair.pubkey)
        } catch {
            fatalError("Failed to create PublicKey from keypair: \(error)")
        }
    }
    
    /// The secret key for this keypair.
    public var seckey: Data {
        return keypair.seckey
    }
    
    /// Creates an account keypair used for signing transactions.
    public init(_ keypair: Ed25519Keypair) {
        self.keypair = keypair
    }
    
    /// Generates a random keypair.
    public static func generate() throws -> Keypair {
        let keypair = try NaClSign.shared.generateKeypair()
        return Keypair(keypair)
    }
    
    /// Creates a Keypair from a seckey byte array.
    public static func fromSeckey(_ seckey: Data, skipValidation: Bool = false) throws -> Keypair {
        let keypair = try NaClSign.shared.keypairFromSeckey(seckey)
        
        if !skipValidation {
            let message = "solana/web3.swift"
            let signData = message.data(using: .utf8)!
            let signature = try NaClSign.shared.sign(signData, seckey: keypair.seckey)
            
            if !NaClSign.shared.verify(signData, signature: signature, pubkey: keypair.pubkey) {
                throw KeypairException("Invalid secret key.")
            }
        }
        
        return Keypair(keypair)
    }
    
    /// Creates a Keypair from a 32-byte seed.
    public static func fromSeed(_ seed: Data) throws -> Keypair {
        let keypair = try NaClSign.shared.keypairFromSeed(seed)
        return Keypair(keypair)
    }
}

