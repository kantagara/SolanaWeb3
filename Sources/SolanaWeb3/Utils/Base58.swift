//
//  Base58.swift
//  SolanaWeb3
//
//  Base58 encoding/decoding utility
//

import Foundation

/// Base58 encoding/decoding
public struct Base58 {
    private static let alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"
    private static let alphabetArray = Array(alphabet)
    private static let base: UInt32 = 58
    
    /// Encode data to base58 string
    public static func encode(_ data: Data) -> String {
        guard !data.isEmpty else { return "" }
        
        // Count leading zeros
        var leadingZeros = 0
        for byte in data {
            if byte == 0 {
                leadingZeros += 1
            } else {
                break
            }
        }
        
        // Convert to BigInt-like representation using array of digits
        var num: [UInt32] = []
        for byte in data {
            var carry = UInt32(byte)
            for j in 0..<num.count {
                carry += num[j] * 256
                num[j] = carry % base
                carry /= base
            }
            while carry > 0 {
                num.append(carry % base)
                carry /= base
            }
        }
        
        // Build result string
        var result = ""
        for _ in 0..<leadingZeros {
            result += String(alphabetArray[0])
        }
        
        for i in stride(from: num.count - 1, through: 0, by: -1) {
            result += String(alphabetArray[Int(num[i])])
        }
        
        return result
    }
    
    /// Decode base58 string to data
    public static func decode(_ string: String) -> Data? {
        guard !string.isEmpty else { return Data() }
        
        // Count leading zeros
        var leadingZeros = 0
        for char in string {
            if char == alphabetArray[0] {
                leadingZeros += 1
            } else {
                break
            }
        }
        
        // Convert from base58
        var num: [UInt32] = []
        for char in string {
            guard let index = alphabetArray.firstIndex(of: char) else {
                return nil
            }
            
            var carry = UInt32(index)
            for j in 0..<num.count {
                carry += num[j] * base
                num[j] = carry % 256
                carry /= 256
            }
            while carry > 0 {
                num.append(carry % 256)
                carry /= 256
            }
        }
        
        // Convert to bytes
        var bytes: [UInt8] = []
        for _ in 0..<leadingZeros {
            bytes.append(0)
        }
        
        for i in stride(from: num.count - 1, through: 0, by: -1) {
            bytes.append(UInt8(num[i]))
        }
        
        return Data(bytes)
    }
}

