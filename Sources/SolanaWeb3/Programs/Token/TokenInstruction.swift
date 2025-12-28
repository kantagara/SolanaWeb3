//
//  TokenInstruction.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Token Instruction enum
public enum TokenInstruction: Int {
    case initializeMint = 0
    case initializeAccount = 1
    case initializeMultisig = 2
    case transfer = 3
    case approve = 4
    case revoke = 5
    case setAuthority = 6
    case mintTo = 7
    case burn = 8
    case closeAccount = 9
    case freezeAccount = 10
    case thawAccount = 11
    case transferChecked = 12
    case approveChecked = 13
    case mintToChecked = 14
    case burnChecked = 15
    case initializeAccount2 = 16
    case syncNative = 17
    case initializeAccount3 = 18
    case initializeMultisig2 = 19
    case initializeMint2 = 20
    case getAccountDataSize = 21
    case initializeImmutableOwner = 22
    case amountToUiAmount = 23
    case uiAmountToAmount = 24
}

