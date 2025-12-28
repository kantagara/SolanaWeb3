//
//  Buffer.swift
//  SolanaWeb3
//
//  Buffer implementation for Solana
//

import Foundation

/// Buffer for reading/writing binary data
public class Buffer {
    private var data: Data
    private var offset: Int = 0
    
    public init(_ data: Data = Data()) {
        self.data = data
    }
    
    public var length: Int {
        return data.count
    }
    
    public var remaining: Int {
        return data.count - offset
    }
    
    public func read(_ length: Int) -> Data? {
        guard offset + length <= data.count else {
            return nil
        }
        let result = data.subdata(in: offset..<(offset + length))
        offset += length
        return result
    }
    
    public func readUInt8() -> UInt8? {
        guard let bytes = read(1) else { return nil }
        return bytes[0]
    }
    
    public func readUInt16() -> UInt16? {
        guard let bytes = read(2) else { return nil }
        return UInt16(bytes[0]) | (UInt16(bytes[1]) << 8)
    }
    
    public func readUInt32() -> UInt32? {
        guard let bytes = read(4) else { return nil }
        return UInt32(bytes[0]) | (UInt32(bytes[1]) << 8) | (UInt32(bytes[2]) << 16) | (UInt32(bytes[3]) << 24)
    }
    
    public func readUInt64() -> UInt64? {
        guard let bytes = read(8) else { return nil }
        var value: UInt64 = 0
        for i in 0..<8 {
            value |= UInt64(bytes[i]) << (i * 8)
        }
        return value
    }
    
    public func write(_ data: Data) {
        self.data.append(data)
    }
    
    public func writeUInt8(_ value: UInt8) {
        write(Data([value]))
    }
    
    public func writeUInt16(_ value: UInt16) {
        var bytes: [UInt8] = []
        bytes.append(UInt8(value & 0xFF))
        bytes.append(UInt8((value >> 8) & 0xFF))
        write(Data(bytes))
    }
    
    public func writeUInt32(_ value: UInt32) {
        var bytes: [UInt8] = []
        for i in 0..<4 {
            bytes.append(UInt8((value >> (i * 8)) & 0xFF))
        }
        write(Data(bytes))
    }
    
    public func writeUInt64(_ value: UInt64) {
        var bytes: [UInt8] = []
        for i in 0..<8 {
            bytes.append(UInt8((value >> (i * 8)) & 0xFF))
        }
        write(Data(bytes))
    }
    
    public func toData() -> Data {
        return data
    }
    
    public func reset() {
        offset = 0
    }
    
    public func seek(_ position: Int) {
        offset = min(position, data.count)
    }
}

/// BufferWriter for writing binary data
public class BufferWriter {
    private var data: Data
    
    public init(_ capacity: Int = 1024) {
        self.data = Data(capacity: capacity)
    }
    
    public func writeUInt8(_ value: UInt8) {
        data.append(value)
    }
    
    public func write(_ data: Data) {
        self.data.append(data)
    }
    
    public func write(_ bytes: [UInt8]) {
        data.append(Data(bytes))
    }
    
    public func write(_ ints: [Int]) {
        data.append(Data(ints.map { UInt8($0) }))
    }
    
    public func toData() -> Data {
        return data
    }
    
    public func toData(slice: Bool) -> Data {
        return data
    }
}

