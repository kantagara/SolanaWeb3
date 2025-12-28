//
//  Lamports.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// The number of lamport per sol (1 billion).
public let lamportsPerSol: UInt64 = 1_000_000_000

/// Converts sol to lamports.
public func solToLamports(_ sol: Double) -> UInt64 {
    return UInt64(sol * Double(lamportsPerSol))
}

/// Converts sol (as Int) to lamports.
public func solToLamports(_ sol: Int) -> UInt64 {
    return UInt64(sol) * lamportsPerSol
}

/// Converts lamports to sol.
public func lamportsToSol(_ lamports: UInt64) -> Double {
    return Double(lamports) / Double(lamportsPerSol)
}

