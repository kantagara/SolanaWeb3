//
//  Connection.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

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
        
        // IMPORTANT:
        // Use `[String: Any]` (not `[String: AnyCodable]`) because `AnyCodable` can encode
        // dictionaries of type `[String: Any]`, but not `[String: AnyCodable]` due to Swift
        // invariance (which leads to `AnyEncodable value cannot be encoded` errors).
        var configDict: [String: Any] = [:]
        if let commitment = config?.commitment ?? self.commitment {
            configDict["commitment"] = commitment.rawValue
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = minContextSlot
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
        
        var configDict: [String: Any] = [:]
        if let commitment = config?.commitment ?? self.commitment {
            configDict["commitment"] = commitment.rawValue
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = minContextSlot
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
        
        var configDict: [String: Any] = [:]
        if let commitment = config?.commitment ?? self.commitment {
            configDict["commitment"] = commitment.rawValue
        }
        if let encoding = config?.encoding {
            configDict["encoding"] = encoding.rawValue
        } else {
            configDict["encoding"] = "base64"
        }
        if let dataSlice = config?.dataSlice {
            var sliceDict: [String: Any] = [:]
            sliceDict["offset"] = dataSlice.offset
            sliceDict["length"] = dataSlice.length
            configDict["dataSlice"] = sliceDict
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = minContextSlot
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
        
        var configDict: [String: Any] = [:]
        if let commitment = config?.commitment ?? self.commitment {
            configDict["commitment"] = commitment.rawValue
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = minContextSlot
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
        
        var configDict: [String: Any] = [:]
        if let skipPreflight = config?.skipPreflight {
            configDict["skipPreflight"] = skipPreflight
        }
        if let preflightCommitment = config?.preflightCommitment {
            configDict["preflightCommitment"] = preflightCommitment.rawValue
        }
        if let maxRetries = config?.maxRetries {
            configDict["maxRetries"] = maxRetries
        }
        if let minContextSlot = config?.minContextSlot {
            configDict["minContextSlot"] = minContextSlot
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
        let params: [AnyCodable] = [
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

