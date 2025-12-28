//
//  AccountInfo.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation
import AnyCodable

/// Account Information
public struct AccountInfo: Codable, Equatable {
    /// The number of lamports assigned to this account, as a UInt64.
    public let lamports: UInt64
    
    /// The base-58 encoded Pubkey of the program this account has been assigned to.
    public let owner: String
    
    /// The data associated with the account (base64 encoded string for binary, or parsed JSON)
    public let data: AnyCodable
    
    /// Indicates if the account contains a program (and is strictly read-only)
    public let executable: Bool
    
    /// The epoch at which this account will next owe rent, as a UInt64.
    public let rentEpoch: UInt64
    
    public init(
        lamports: UInt64,
        owner: String,
        data: AnyCodable,
        executable: Bool,
        rentEpoch: UInt64
    ) {
        self.lamports = lamports
        self.owner = owner
        self.data = data
        self.executable = executable
        self.rentEpoch = rentEpoch
    }
    
    /// Returns binary data if data is a string (base64 encoded)
    public var binaryData: String? {
        if let string = data.value as? String {
            return string
        }
        return nil
    }
    
    /// Returns parsed data if data is a dictionary
    public var parsedData: [String: AnyCodable]? {
        if let dict = data.value as? [String: AnyCodable] {
            return dict
        }
        if let dict = data.value as? [String: Any] {
            return dict.mapValues { AnyCodable($0) }
        }
        return nil
    }
    
    /// Returns true if data is binary (string)
    public var isBinary: Bool {
        return data.value is String
    }
}

