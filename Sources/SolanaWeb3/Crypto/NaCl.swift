//
//  NaCl.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation
import TweetNacl

/// Public key length in bytes.
public let pubkeyLength: Int = 32

/// Secret key length in bytes.
public let seckeyLength: Int = 64

/// Signature length in bytes.
public let signatureLength: Int = 64

/// The Maximum length in bytes of derived public key seed.
public let maxSeedLength: Int = 32

/// Ed25519 Keypair
public struct Ed25519Keypair {
    /// The Ed25519 public key.
    public let pubkey: Data
    
    /// The Ed25519 signing key.
    public let seckey: Data
    
    public init(pubkey: Data, seckey: Data) {
        assert(pubkey.count == pubkeyLength, "Invalid public key length")
        assert(seckey.count == seckeyLength, "Invalid secret key length")
        self.pubkey = pubkey
        self.seckey = seckey
    }
}

/// NaCl Sign
public struct NaClSign {
    public static let shared = NaClSign()
    
    private init() {}
    
    /// Generates a random keypair.
    public func generateKeypair() throws -> Ed25519Keypair {
        let seed = try TweetNacl.NaclUtil.secureRandomData(count: maxSeedLength)
        return try keypairFromSeed(seed)
    }
    
    /// Creates a keypair from a secret key byte array.
    public func keypairFromSeckey(_ seckey: Data) throws -> Ed25519Keypair {
        guard seckey.count == seckeyLength else {
            throw KeypairException("Invalid secret key length \(seckey.count).")
        }
        
        let keyPair = try TweetNacl.NaclSign.KeyPair.keyPair(fromSecretKey: seckey)
        return Ed25519Keypair(
            pubkey: keyPair.publicKey,
            seckey: keyPair.secretKey
        )
    }
    
    /// Creates a keypair from a 32-byte seed.
    public func keypairFromSeed(_ seed: Data) throws -> Ed25519Keypair {
        guard seed.count == maxSeedLength else {
            throw KeypairException("Invalid seed length \(seed.count).")
        }
        
        let keyPair = try TweetNacl.NaclSign.KeyPair.keyPair(fromSeed: seed)
        return Ed25519Keypair(
            pubkey: keyPair.publicKey,
            seckey: keyPair.secretKey
        )
    }
    
    /// Signs message using the seckey and returns the signature (detached).
    public func sign(_ message: Data, seckey: Data) throws -> Data {
        let signature = try TweetNacl.NaclSign.signDetached(message: message, secretKey: seckey)
        return signature
    }
    
    /// Returns true if the signature was derived by signing the message using pubkey's secret key.
    public func verify(_ message: Data, signature: Data, pubkey: Data) -> Bool {
        guard signature.count == signatureLength else {
            return false
        }
        do {
            return try TweetNacl.NaclSign.signDetachedVerify(message: message, sig: signature, publicKey: pubkey)
        } catch {
            return false
        }
    }
}

