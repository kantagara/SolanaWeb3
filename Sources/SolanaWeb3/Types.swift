//
//  Types.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// A unique base-58 encoded hash that identifies a record (block).
public typealias Blockhash = String

/// A base-58 encoded transaction signature.
public typealias TransactionSignature = String

/// Commitment level
public enum Commitment: String, Codable {
    case processed
    case confirmed
    case finalized
}

/// Cluster endpoint
public struct Cluster {
    public let uri: URL
    
    public init(_ uri: URL) {
        self.uri = uri
    }
    
    public static let mainnet = Cluster(URL(string: "https://api.mainnet-beta.solana.com")!)
    public static let devnet = Cluster(URL(string: "https://api.devnet.solana.com")!)
    public static let testnet = Cluster(URL(string: "https://api.testnet.solana.com")!)
    public static let localhost = Cluster(URL(string: "http://localhost:8899")!)
    
    public func toWebsocket() -> Cluster {
        let wsURL = uri.absoluteString
            .replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")
        return Cluster(URL(string: wsURL)!)
    }
}

