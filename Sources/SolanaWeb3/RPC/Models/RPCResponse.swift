//
//  RPCResponse.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// JSON RPC Response with context
public struct RPCContextResponse<T: Codable>: Codable {
    public let context: RPCContext
    public let value: T?
    
    public init(context: RPCContext, value: T?) {
        self.context = context
        self.value = value
    }
}

/// RPC Context
public struct RPCContext: Codable {
    public let slot: UInt64
    
    public init(slot: UInt64) {
        self.slot = slot
    }
}

/// JSON RPC Success Response
public struct RPCSuccessResponse<T: Codable>: Codable {
    public let result: T?
    
    public init(result: T?) {
        self.result = result
    }
}

/// JSON RPC Error Response
public struct RPCErrorResponse: Codable, Error {
    public let code: Int
    public let message: String
    public let data: AnyCodable?
    
    public init(code: Int, message: String, data: AnyCodable? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}

/// JSON RPC Response
public enum RPCResponse<T: Codable> {
    case success(RPCSuccessResponse<T>)
    case error(RPCErrorResponse)
}

/// Health Status
public struct HealthStatus: Codable {
    public let status: String
    
    public init(status: String) {
        self.status = status
    }
}

