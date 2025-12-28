//
//  ShortVec.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Shortvec Encoding (Compact-u16 Format)
/// ------------------------------------------------------------------------------------------------

/// Returns the short-vec encoded length.
public func decodeLength(_ buffer: inout Buffer) -> Int? {
    var len = 0
    var size = 0
    
    while size < buffer.remaining {
        guard let byte = buffer.readUInt8() else {
            return nil
        }
        
        len |= Int(byte & 0x7f) << (size * 7)
        size += 1
        
        if (byte & 0x80) == 0 {
            break
        }
    }
    
    return len
}

/// Encodes length into a byte array.
public func encodeLength(_ length: Int) -> Data {
    assert(length >= 0, "Length must be non-negative")
    
    var bytes: [UInt8] = []
    var remainingLength = length
    
    while true {
        var elem = remainingLength & 0x7f
        remainingLength >>= 7
        
        if remainingLength == 0 {
            bytes.append(UInt8(elem))
            break
        } else {
            elem |= 0x80
            bytes.append(UInt8(elem))
        }
    }
    
    return Data(bytes)
}

