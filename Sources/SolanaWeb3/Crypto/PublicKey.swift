//
//  PublicKey.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation
import CryptoKit

/// Public Key
public struct PublicKey: Hashable, Codable, CustomStringConvertible {
    /// The public key's ed25519 value as Data
    private let value: Data
    
    /// Creates a PublicKey from an ed25519 public key value.
    public init(_ value: Data) throws {
        guard value.count <= pubkeyLength else {
            throw PublicKeyException.invalidLength(value.count)
        }
        // Pad to 32 bytes if needed
        if value.count < pubkeyLength {
            var padded = Data(count: pubkeyLength)
            padded.replaceSubrange((pubkeyLength - value.count)..<pubkeyLength, with: value)
            self.value = padded
        } else {
            self.value = value
        }
    }
    
    /// Creates a default PublicKey (0 => '11111111111111111111111111111111').
    public static func zero() -> PublicKey {
        return try! PublicKey(Data(count: pubkeyLength))
    }
    
    /// Creates a PublicKey from a base-58 encoded pubkey.
    public static func fromString(_ pubkey: String) throws -> PublicKey {
        return try fromBase58(pubkey)
    }
    
    /// Creates a PublicKey from a base-58 encoded pubkey.
    public static func fromBase58(_ pubkey: String) throws -> PublicKey {
        guard let data = Base58.decode(pubkey) else {
            throw PublicKeyException("Invalid base58 encoded public key")
        }
        return try PublicKey(data)
    }
    
    /// Creates a PublicKey from a base-58 encoded pubkey.
    /// Returns nil if pubkey is omitted.
    public static func tryFromBase58(_ pubkey: String?) -> PublicKey? {
        guard let pubkey = pubkey else { return nil }
        return try? fromBase58(pubkey)
    }
    
    /// Creates a PublicKey from a base-64 encoded pubkey.
    public static func fromBase64(_ pubkey: String) throws -> PublicKey {
        guard let data = Data(base64Encoded: pubkey) else {
            throw PublicKeyException("Invalid base64 encoded public key")
        }
        return try PublicKey(data)
    }
    
    /// Creates a PublicKey from a base-64 encoded pubkey.
    /// Returns nil if pubkey is omitted.
    public static func tryFromBase64(_ pubkey: String?) -> PublicKey? {
        guard let pubkey = pubkey else { return nil }
        return try? fromBase64(pubkey)
    }
    
    /// Creates a PublicKey from a byte array.
    public static func fromBytes(_ pubkey: Data) throws -> PublicKey {
        return try PublicKey(pubkey)
    }
    
    /// Creates a PublicKey from a byte array.
    /// Returns nil if pubkey is omitted.
    public static func tryFromBytes(_ pubkey: Data?) -> PublicKey? {
        guard let pubkey = pubkey else { return nil }
        return try? PublicKey(pubkey)
    }
    
    /// Returns this PublicKey as a base-58 encoded string.
    public func toBase58() -> String {
        return Base58.encode(toBytes())
    }
    
    /// Returns this PublicKey as a base-64 encoded string.
    public func toBase64() -> String {
        return toBytes().base64EncodedString()
    }
    
    /// Returns this PublicKey as a byte array.
    public func toBytes() -> Data {
        return value
    }
    
    /// Returns this PublicKey as a base-58 encoded string.
    public var description: String {
        return toBase58()
    }
    
    // MARK: - Codable
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        self = try PublicKey.fromBase58(string)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(toBase58())
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
    
    // MARK: - Program Address Methods
    
    /// Derives a PublicKey from another pubkey, seed, and programId.
    public static func createWithSeed(
        pubkey: PublicKey,
        seed: String,
        programId: PublicKey
    ) throws -> PublicKey {
        let seedBytes = seed.data(using: .utf8)!
        var buffer = Data()
        buffer.append(pubkey.toBytes())
        buffer.append(seedBytes)
        buffer.append(programId.toBytes())
        
        let hash = SHA256.hash(data: buffer)
        return try PublicKey(Data(hash))
    }
    
    /// Derives a program address from the seeds and programId.
    public static func createProgramAddress(
        seeds: [[UInt8]],
        programId: PublicKey
    ) throws -> PublicKey {
        var buffer = Data()
        
        for seed in seeds {
            guard seed.count <= maxSeedLength else {
                throw PublicKeyException("Invalid seed length.")
            }
            buffer.append(Data(seed))
        }
        
        buffer.append(programId.toBytes())
        buffer.append("ProgramDerivedAddress".data(using: .utf8)!)
        
        let hash = SHA256.hash(data: buffer)
        let digestBytes = Data(hash)
        
        if isOnCurve(digestBytes) {
            throw ED25519Exception(
                "Invalid seeds \(seeds)\n" +
                "The public key address must fall off the ed25519 curve."
            )
        }
        
        return try PublicKey(digestBytes)
    }
    
    /// Finds a valid program address for the given seeds and programId.
    public static func findProgramAddress(
        seeds: [[UInt8]],
        programId: PublicKey
    ) throws -> ProgramAddress {
        for nonce in stride(from: 255, through: 1, by: -1) {
            do {
                let seedsWithNonce = seeds + [[UInt8(nonce)]]
                let address = try createProgramAddress(seeds: seedsWithNonce, programId: programId)
                return ProgramAddress(address: address, nonce: UInt8(nonce))
            } catch {
                // Continue to next nonce
            }
        }
        
        throw PublicKeyException("Unable to find a viable program address nonce.")
    }
    
    /// Returns true if pubkey falls on the ed25519 curve.
    public static func isOnCurve(_ pubkey: Data) -> Bool {
        return NaClLowLevel.isOnCurve(pubkey) == 1
    }
    
    /// Finds the associated token address for an existing wallet and tokenMint.
    public static func findAssociatedTokenAddress(
        wallet: PublicKey,
        tokenMint: PublicKey
    ) throws -> ProgramAddress {
        return try findProgramAddress(
            seeds: [
                Array(wallet.toBytes()),
                Array(TokenProgram.programId.toBytes()),
                Array(tokenMint.toBytes())
            ],
            programId: AssociatedTokenProgram.programId
        )
    }
}

/// Program Address
public struct ProgramAddress {
    public let address: PublicKey
    public let nonce: UInt8
    
    public init(address: PublicKey, nonce: UInt8) {
        self.address = address
        self.nonce = nonce
    }
}

