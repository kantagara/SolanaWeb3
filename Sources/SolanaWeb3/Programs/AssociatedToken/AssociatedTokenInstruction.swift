//
//  AssociatedTokenInstruction.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Associated Token Instruction enum
public enum AssociatedTokenInstruction: Int {
    case create = 0
    case createIdempotent = 1
    case recoverNested = 2
}

