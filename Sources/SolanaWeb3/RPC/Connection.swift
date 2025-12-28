//
//  Connection.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation
import AnyCodable

/// Connection to Solana JSON RPC API
public class Connection {
    /// The HTTP cluster
    public let cluster: Cluster
    
    /// The default commitment level applied to all methods that query bank state.
    public let commitment: Commitment?
    
    /// HTTP client
    private let httpClient: HTTPClient
    
    /// Creates a connection to invoke JSON RPC methods.
    public init(
        _ cluster: Cluster,
        commitment: Commitment = .confirmed
    ) {
        self.cluster = cluster
        self.commitment = commitment
        self.httpClient = HTTPClient(cluster.uri)
    }
    
    /// Creates a connection with a custom RPC URL.
    /// - Parameters:
    ///   - customRpcUrl: Custom RPC endpoint URL (e.g., "https://your-rpc-endpoint.com")
    ///   - commitment: The default commitment level
    public convenience init(
        customRpcUrl: String,
        commitment: Commitment = .confirmed
    ) throws {
        guard let url = URL(string: customRpcUrl) else {
            throw SolanaException("Invalid RPC URL: \(customRpcUrl)")
        }
        let cluster = Cluster(url)
        self.init(cluster, commitment: commitment)
    }
    
    /// Returns the health status of the cluster.
    public func health() async throws -> HealthStatus {
        return try await httpClient.health()
    }
    
    /// Returns the latest blockhash
    public func getLatestBlockhash(
        config: GetLatestBlockhashConfig? = nil
    ) async throws -> BlockhashWithExpiryBlockHeight {
        var params: [AnyCodable] = []
        
        var configDict: [String: AnyCodable] = [:]
        if let commitment = config?.commitment ?? self.commitment {
            configDict["commitment"] = AnyCodable(commitment.rawValue)
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = AnyCodable(minContextSlot)
        }
        if !configDict.isEmpty {
            params.append(AnyCodable(configDict))
        }
        
        let response = try await httpClient.send(
            method: "getLatestBlockhash",
            params: params,
            responseType: RPCContextResponse<BlockhashWithExpiryBlockHeight>.self
        )
        
        guard let value = response.result?.value else {
            throw RPCError.noResult
        }
        
        return value
    }
    
    /// Returns the balance of the account of provided pubkey
    public func getBalance(
        _ pubkey: PublicKey,
        config: GetBalanceConfig? = nil
    ) async throws -> UInt64 {
        var params: [AnyCodable] = [AnyCodable(pubkey.toBase58())]
        
        var configDict: [String: AnyCodable] = [:]
        if let commitment = config?.commitment ?? self.commitment {
            configDict["commitment"] = AnyCodable(commitment.rawValue)
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = AnyCodable(minContextSlot)
        }
        if !configDict.isEmpty {
            params.append(AnyCodable(configDict))
        }
        
        let response = try await httpClient.send(
            method: "getBalance",
            params: params,
            responseType: RPCContextResponse<UInt64>.self
        )
        
        guard let value = response.result?.value else {
            throw RPCError.noResult
        }
        
        return value
    }
    
    /// Returns all information associated with the account of the provided pubkey.
    public func getAccountInfo(
        _ pubkey: PublicKey,
        config: GetAccountInfoConfig? = nil
    ) async throws -> AccountInfo? {
        var params: [AnyCodable] = [AnyCodable(pubkey.toBase58())]
        
        var configDict: [String: AnyCodable] = [:]
        if let commitment = config?.commitment ?? self.commitment {
            configDict["commitment"] = AnyCodable(commitment.rawValue)
        }
        if let encoding = config?.encoding {
            configDict["encoding"] = AnyCodable(encoding.rawValue)
        } else {
            configDict["encoding"] = AnyCodable("base64")
        }
        if let dataSlice = config?.dataSlice {
            var sliceDict: [String: AnyCodable] = [:]
            sliceDict["offset"] = AnyCodable(dataSlice.offset)
            sliceDict["length"] = AnyCodable(dataSlice.length)
            configDict["dataSlice"] = AnyCodable(sliceDict)
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = AnyCodable(minContextSlot)
        }
        if !configDict.isEmpty {
            params.append(AnyCodable(configDict))
        }
        
        let response = try await httpClient.send(
            method: "getAccountInfo",
            params: params,
            responseType: RPCContextResponse<AccountInfo>.self
        )
        
        return response.result?.value
    }
    
    /// Returns the current block height of the node.
    public func getBlockHeight(
        config: GetBlockHeightConfig? = nil
    ) async throws -> UInt64 {
        var params: [AnyCodable] = []
        
        var configDict: [String: AnyCodable] = [:]
        if let commitment = config?.commitment ?? self.commitment {
            configDict["commitment"] = AnyCodable(commitment.rawValue)
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = AnyCodable(minContextSlot)
        }
        if !configDict.isEmpty {
            params.append(AnyCodable(configDict))
        }
        
        let response = try await httpClient.send(
            method: "getBlockHeight",
            params: params,
            responseType: RPCContextResponse<UInt64>.self
        )
        
        guard let value = response.result?.value else {
            throw RPCError.noResult
        }
        
        return value
    }
    
    /// Sends a transaction
    public func sendTransaction(
        _ transaction: Transaction,
        config: SendTransactionConfig? = nil
    ) async throws -> TransactionSignature {
        let serializedTransaction = transaction.serializeToBase64()
        
        var params: [AnyCodable] = [AnyCodable(serializedTransaction)]
        
        var configDict: [String: AnyCodable] = [:]
        if let skipPreflight = config?.skipPreflight {
            configDict["skipPreflight"] = AnyCodable(skipPreflight)
        }
        if let preflightCommitment = config?.preflightCommitment {
            configDict["preflightCommitment"] = AnyCodable(preflightCommitment.rawValue)
        }
        if let maxRetries = config?.maxRetries {
            configDict["maxRetries"] = AnyCodable(maxRetries)
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = AnyCodable(minContextSlot)
        }
        if !configDict.isEmpty {
            params.append(AnyCodable(configDict))
        }
        
        let response = try await httpClient.send(
            method: "sendTransaction",
            params: params,
            responseType: TransactionSignature.self
        )
        
        guard let signature = response.result else {
            throw RPCError.noResult
        }
        
        return signature
    }
    
    /// Requests an airdrop of lamports to pubkey
    public func requestAirdrop(
        _ pubkey: PublicKey,
        lamports: UInt64
    ) async throws -> TransactionSignature {
        var params: [AnyCodable] = [
            AnyCodable(pubkey.toBase58()),
            AnyCodable(lamports)
        ]
        
        let response = try await httpClient.send(
            method: "requestAirdrop",
            params: params,
            responseType: TransactionSignature.self
        )
        
        guard let signature = response.result else {
            throw RPCError.noResult
        }
        
        return signature
    }
    
    /// Requests an airdrop and waits for confirmation
    public func requestAndConfirmAirdrop(
        _ pubkey: PublicKey,
        lamports: UInt64
    ) async throws -> TransactionSignature {
        let signature = try await requestAirdrop(pubkey, lamports: lamports)
        // TODO: Implement confirmation waiting
        return signature
    }
}

