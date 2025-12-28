//
//  NaClLowLevel.swift
//  SolanaWeb3
//
//  A Swift implementation of @solana-web3.js' is_on_curve() method.
//  Source code: https://github.com/solana-labs/solana-web3.js/blob/master/src/publickey.ts#L241
//

import Foundation
import TweetNacl

/// NaCl Low Level
public struct NaClLowLevel {
    
    private static func gf(_ initialValues: [Int]? = nil) -> [Int] {
        var r = Array(repeating: 0, count: 16)
        if let initialValues = initialValues {
            for i in 0..<min(initialValues.count, 16) {
                r[i] = initialValues[i]
            }
        }
        return r
    }
    
    private static let gf1 = gf([1])
    private static let D = gf([
        0x78a3, 0x1359, 0x4dca, 0x75eb, 0xd8ab, 0x4141, 0x0a4d, 0x0070,
        0xe898, 0x7779, 0x4079, 0x8cc7, 0xfe73, 0x2b6f, 0x6cee, 0x5203,
    ])
    private static let I = gf([
        0xa0b0, 0x4a0e, 0x1b27, 0xc4ee, 0xe478, 0xad2f, 0x1806, 0x2f43,
        0xd7a7, 0x3dfb, 0x0099, 0x2b4d, 0xdf0b, 0x4fc1, 0x2480, 0x2b83,
    ])
    
    private static func set25519(_ r: inout [Int], _ a: [Int]) {
        for i in 0..<16 {
            r[i] = a[i]
        }
    }
    
    private static func unpack25519(_ o: inout [Int], _ n: Data) {
        for i in 0..<16 {
            o[i] = Int(n[2*i]) + (Int(n[2*i+1]) << 8)
        }
        o[15] &= 0x7fff
    }
    
    private static func A(_ o: inout [Int], _ a: [Int], _ b: [Int]) {
        for i in 0..<16 {
            o[i] = a[i] + b[i]
        }
    }
    
    private static func Z(_ o: inout [Int], _ a: [Int], _ b: [Int]) {
        for i in 0..<16 {
            o[i] = a[i] - b[i]
        }
    }
    
    private static func M(_ o: inout [Int], _ a: [Int], _ b: [Int]) {
        var t = Array(repeating: 0, count: 31)
        for i in 0..<16 {
            for j in 0..<16 {
                t[i+j] += a[i] * b[j]
            }
        }
        let len = 16 - 1
        for i in 0..<len {
            t[i] += 38 * t[i+16]
        }
        for i in 0..<16 {
            o[i] = t[i]
        }
        car25519(&o)
        car25519(&o)
    }
    
    private static func car25519(_ o: inout [Int]) {
        for i in 0..<16 {
            o[i] += 65536
            let c = o[i] / 65536
            let idx = (i+1) * (i < 15 ? 1 : 0)
            o[idx] += c - 1 + 37 * (c-1) * (i == 15 ? 1 : 0)
            o[i] -= c * 65536
        }
    }
    
    private static func S(_ o: inout [Int], _ a: [Int]) {
        M(&o, a, a)
    }
    
    private static func pow2523(_ o: inout [Int], _ input: [Int]) {
        var c = gf(input)
        for a in stride(from: 250, through: 0, by: -1) {
            S(&c, c)
            if a != 1 {
                M(&c, c, input)
            }
        }
        for a in 0..<16 {
            o[a] = c[a]
        }
    }
    
    private static func neq25519(_ a: [Int], _ b: [Int]) -> Int {
        var c = Data(count: 32)
        var d = Data(count: 32)
        pack25519(&c, a)
        pack25519(&d, b)
        // Compare byte by byte
        return c == d ? 0 : 1
    }
    
    private static func pack25519(_ o: inout Data, _ n: [Int]) {
        var t = gf(n)
        car25519(&t)
        car25519(&t)
        car25519(&t)
        var m = gf()
        for _ in 0..<2 {
            m[0] = t[0] - 0xffed
            for i in 1..<15 {
                m[i] = t[i] - 0xffff - ((m[i-1]>>16) & 1)
                m[i-1] &= 0xffff
            }
            m[15] = t[15] - 0x7fff - ((m[14]>>16) & 1)
            let b = (m[15]>>16) & 1
            m[14] &= 0xffff
            sel25519(&t, &m, 1-b)
        }
        for i in 0..<16 {
            o[2*i] = UInt8(t[i] & 0xff)
            o[2*i+1] = UInt8(t[i]>>8)
        }
    }
    
    private static func sel25519(_ p: inout [Int], _ q: inout [Int], _ b: Int) {
        let c = ~(b-1)
        for i in 0..<16 {
            let t = c & (p[i] ^ q[i])
            p[i] ^= t
            q[i] ^= t
        }
    }
    
    /// Returns a non-zero value if publicKey falls on the ed25519 curve.
    public static func isOnCurve(_ publicKey: Data) -> Int {
        var r = [gf(), gf(), gf(), gf()]
        var t = gf()
        var chk = gf()
        var num = gf()
        var den = gf()
        var den2 = gf()
        var den4 = gf()
        var den6 = gf()
        
        set25519(&r[2], gf1)
        unpack25519(&r[1], publicKey)
        S(&num, r[1])
        M(&den, num, D)
        Z(&num, num, r[2])
        A(&den, r[2], den)
        
        S(&den2, den)
        S(&den4, den2)
        M(&den6, den4, den2)
        M(&t, den6, num)
        M(&t, t, den)
        
        pow2523(&t, t)
        M(&t, t, num)
        M(&t, t, den)
        M(&t, t, den)
        M(&r[0], t, den)
        
        S(&chk, r[0])
        M(&chk, chk, den)
        if neq25519(chk, num) != 0 {
            M(&r[0], r[0], I)
        }
        
        S(&chk, r[0])
        M(&chk, chk, den)
        if neq25519(chk, num) != 0 {
            return 0
        }
        
        return 1
    }
}

