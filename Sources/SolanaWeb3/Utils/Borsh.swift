//
//  Borsh.swift
//  SolanaWeb3
//
//  Borsh encoding helpers using beet-swift
//

import Foundation
import Beet

/// Borsh encoding helpers using beet-swift
public struct Borsh {
    public static let shared = Borsh()
    
    private init() {}
    
    /// Encodes a u64 value using beet-swift
    public func encodeU64(_ value: UInt64) -> Data {
        var buffer = Data(count: 8)
        // Use Beet's u64 class (not the typealias from Types.swift)
        // Import Beet module's u64 class directly
        let u64Beet = u64()
        u64Beet.write(buf: &buffer, offset: 0, value: value)
        return buffer
    }
    
    /// Encodes a u8 value using beet-swift
    public func encodeU8(_ value: UInt8) -> Data {
        var buffer = Data(count: 1)
        // Use Beet's u8 class
        let u8Beet = u8()
        u8Beet.write(buf: &buffer, offset: 0, value: value)
        return buffer
    }
    
    /// Encodes a pubkey (base58 string) as a Rust string using beet-swift
    /// Format: u32 length (little-endian) + UTF-8 bytes
    public func encodePubkey(_ pubkey: String) -> Data {
        return encodeRustString(pubkey)
    }
    
    /// Encodes a Rust string using beet-swift
    /// Format: u32 length (little-endian) + UTF-8 bytes
    public func encodeRustString(_ string: String) -> Data {
        let stringBeet = Utf8String()
        let fixedBeet = stringBeet.toFixedFromValue(val: string)
        
        var buffer = Data(count: Int(fixedBeet.byteSize))
        switch fixedBeet.value {
        case .collection(let collectionBeet):
            collectionBeet.write(buf: &buffer, offset: 0, value: string)
        case .scalar:
            fatalError("String should be a collection type")
        }
        return buffer
    }
    
    /// Encodes an optional pubkey (base58 string) using beet-swift COption
    /// Format: u8 (0 = None, 1 = Some) + optional Rust string
    public func encodeOptionalPubkey(_ pubkey: String?) -> Data {
        let stringBeet = Utf8String()
        let coptionBeet = coption(inner: .fixableBeat(stringBeet))
        
        let fixedBeet = coptionBeet.toFixedFromValue(val: pubkey as Any)
        var buffer = Data(count: Int(fixedBeet.byteSize))
        
        switch fixedBeet.value {
        case .scalar(let scalar):
            scalar.write(buf: &buffer, offset: 0, value: pubkey as Any)
        case .collection:
            fatalError("COption should be a scalar type")
        }
        return buffer
    }
}

