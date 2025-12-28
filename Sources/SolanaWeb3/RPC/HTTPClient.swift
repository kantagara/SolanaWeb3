//
//  HTTPClient.swift
//  SolanaWeb3
//
//  HTTP JSON RPC Client
//

import Foundation
import AnyCodable

/// HTTP JSON RPC Client
public class HTTPClient {
    private let baseURL: URL
    private let session: URLSession
    
    public init(_ baseURL: URL) {
        self.baseURL = baseURL
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    /// Send JSON RPC request
    public func send<T: Codable>(
        method: String,
        params: [AnyCodable],
        responseType: T.Type
    ) async throws -> RPCSuccessResponse<T> {
        let request = JSONRPCRequest(
            jsonrpc: "2.0",
            id: UUID().uuidString,
            method: method,
            params: params
        )
        
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RPCError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw RPCError.httpError(httpResponse.statusCode)
        }
        
        let jsonResponse = try JSONDecoder().decode(JSONRPCResponse<T>.self, from: data)
        
        if let error = jsonResponse.error {
            throw RPCError.rpcError(error)
        }
        
        guard let result = jsonResponse.result else {
            throw RPCError.noResult
        }
        
        return RPCSuccessResponse(result: result)
    }
    
    /// Health check
    public func health() async throws -> HealthStatus {
        let healthURL = baseURL.appendingPathComponent("health")
        var request = URLRequest(url: healthURL)
        request.httpMethod = "GET"
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RPCError.invalidResponse
        }
        
        if httpResponse.statusCode == 200 {
            return HealthStatus(status: "ok")
        } else {
            return HealthStatus(status: "error")
        }
    }
    
    deinit {
        session.invalidateAndCancel()
    }
}

/// JSON RPC Request
private struct JSONRPCRequest: Codable {
    let jsonrpc: String
    let id: String
    let method: String
    let params: [AnyCodable]
}

/// JSON RPC Response
private struct JSONRPCResponse<T: Codable>: Codable {
    let jsonrpc: String?
    let id: String?
    let result: T?
    let error: RPCErrorResponse?
}

/// RPC Error
public enum RPCError: Error {
    case invalidResponse
    case httpError(Int)
    case rpcError(RPCErrorResponse)
    case noResult
    case decodingError(Error)
}

