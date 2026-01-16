//
//  Borsh.swift
//  SolanaWeb3
//
//  Borsh encoding helpers (no external dependencies)
//

import Foundation

/// Minimal Borsh encoding helpers used by this library.
///
/// Note: This currently implements only the primitives we need for instruction data:
/// - u8, u32, u64 (little-endian)
/// - Rust `String` (u32 length + UTF-8 bytes)
/// - `Option<String>` encoded as COption-style: u8 tag (0/1) + value if present
public struct Borsh {
    public static let shared = Borsh()
    
    private init() {}
    
    /// Encodes a u64 value (little-endian)
    public func encodeU64(_ value: UInt64) -> Data {
        var le = value.littleEndian
        return Data(bytes: &le, count: MemoryLayout<UInt64>.size)
    }
    
    /// Encodes a u8 value
    public func encodeU8(_ value: UInt8) -> Data {
        return Data([value])
    }
    
    /// Encodes a pubkey (base58 string) as a Rust string.
    public func encodePubkey(_ pubkey: String) -> Data {
        return encodeRustString(pubkey)
    }
    
    /// Encodes a Rust string.
    /// Format: u32 length (little-endian) + UTF-8 bytes
    public func encodeRustString(_ string: String) -> Data {
        let bytes = Array(string.utf8)
        let len = UInt32(bytes.count)
        return encodeU32(len) + Data(bytes)
    }
    
    /// Encodes an optional pubkey (base58 string).
    /// Format: u8 (0 = None, 1 = Some) + optional Rust string
    public func encodeOptionalPubkey(_ pubkey: String?) -> Data {
        guard let pubkey else {
            return encodeU8(0)
        }
        return encodeU8(1) + encodeRustString(pubkey)
    }

    // MARK: - Private helpers

    /// Encodes a u32 value (little-endian)
    private func encodeU32(_ value: UInt32) -> Data {
        var le = value.littleEndian
        return Data(bytes: &le, count: MemoryLayout<UInt32>.size)
    }
}

