//
//  SystemInstruction.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// System Instruction enum
public enum SystemInstruction: Int {
    case create = 0
    case assign = 1
    case transfer = 2
    case createWithSeed = 3
    case advanceNonceAccount = 4
    case withdrawNonceAccount = 5
    case initializeNonceAccount = 6
    case authorizeNonceAccount = 7
    case allocate = 8
    case allocateWithSeed = 9
    case assignWithSeed = 10
    case transferWithSeed = 11
    case upgradeNonceAccount = 12
}

