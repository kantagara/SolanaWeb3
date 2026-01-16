//
//  NaCl.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation
#if canImport(CryptoKit)
import CryptoKit
#endif

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
#if canImport(CryptoKit)
        let privateKey = Curve25519.Signing.PrivateKey()
        let seed = privateKey.rawRepresentation
        let pubkey = privateKey.publicKey.rawRepresentation
        let seckey = seed + pubkey
        return Ed25519Keypair(pubkey: pubkey, seckey: seckey)
#else
        throw ED25519Exception("CryptoKit is not available on this platform.")
#endif
    }
    
    /// Creates a keypair from a secret key byte array.
    public func keypairFromSeckey(_ seckey: Data) throws -> Ed25519Keypair {
        guard seckey.count == seckeyLength else {
            throw KeypairException("Invalid secret key length \(seckey.count).")
        }
#if canImport(CryptoKit)
        let seed = seckey.prefix(maxSeedLength)
        let providedPubkey = seckey.suffix(pubkeyLength)
        do {
            let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: seed)
            let derivedPubkey = privateKey.publicKey.rawRepresentation
            guard derivedPubkey == providedPubkey else {
                throw KeypairException("Invalid secret key.")
            }
            let normalizedSeckey = seed + derivedPubkey
            return Ed25519Keypair(pubkey: derivedPubkey, seckey: normalizedSeckey)
        } catch let e as KeypairException {
            throw e
        } catch {
            throw KeypairException("Invalid secret key.")
        }
#else
        throw ED25519Exception("CryptoKit is not available on this platform.")
#endif
    }
    
    /// Creates a keypair from a 32-byte seed.
    public func keypairFromSeed(_ seed: Data) throws -> Ed25519Keypair {
        guard seed.count == maxSeedLength else {
            throw KeypairException("Invalid seed length \(seed.count).")
        }
#if canImport(CryptoKit)
        do {
            let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: seed)
            let pubkey = privateKey.publicKey.rawRepresentation
            let seckey = seed + pubkey
            return Ed25519Keypair(pubkey: pubkey, seckey: seckey)
        } catch {
            throw KeypairException("Invalid seed.")
        }
#else
        throw ED25519Exception("CryptoKit is not available on this platform.")
#endif
    }
    
    /// Signs message using the seckey and returns the signature (detached).
    public func sign(_ message: Data, seckey: Data) throws -> Data {
#if canImport(CryptoKit)
        guard seckey.count == seckeyLength else {
            throw KeypairException("Invalid secret key length \(seckey.count).")
        }
        let seed = seckey.prefix(maxSeedLength)
        do {
            let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: seed)
            return try privateKey.signature(for: message)
        } catch {
            throw KeypairException("Invalid secret key.")
        }
#else
        throw ED25519Exception("CryptoKit is not available on this platform.")
#endif
    }
    
    /// Returns true if the signature was derived by signing the message using pubkey's secret key.
    public func verify(_ message: Data, signature: Data, pubkey: Data) -> Bool {
        guard signature.count == signatureLength else {
            return false
        }
#if canImport(CryptoKit)
        guard pubkey.count == pubkeyLength else {
            return false
        }
        do {
            let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: pubkey)
            return publicKey.isValidSignature(signature, for: message)
        } catch {
            return false
        }
#else
        return false
#endif
    }
}

