//
//  AddressLookupTableAccount.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Address Lookup Table State
public struct AddressLookupTableState: Codable, Equatable {
    public let typeIndex: Int
    public let deactivationSlot: UInt64
    public let lastExtendedSlot: UInt64
    public let lastExtendedSlotStartIndex: UInt8
    public let authority: PublicKey?
    public let addresses: [PublicKey]
    
    public init(
        typeIndex: Int = 1,
        deactivationSlot: UInt64,
        lastExtendedSlot: UInt64,
        lastExtendedSlotStartIndex: UInt8,
        authority: PublicKey?,
        addresses: [PublicKey]
    ) {
        self.typeIndex = typeIndex
        self.deactivationSlot = deactivationSlot
        self.lastExtendedSlot = lastExtendedSlot
        self.lastExtendedSlotStartIndex = lastExtendedSlotStartIndex
        self.authority = authority
        self.addresses = addresses
    }
    
    public var isActive: Bool {
        return deactivationSlot == UInt64.max
    }
}

/// Address Lookup Table Account
public struct AddressLookupTableAccount: Codable, Equatable {
    public let key: PublicKey
    public let state: AddressLookupTableState
    
    public init(key: PublicKey, state: AddressLookupTableState) {
        self.key = key
        self.state = state
    }
    
    public var isActive: Bool {
        return state.isActive
    }
}

