import XCTest
import AnyCodable
@testable import SolanaWeb3

final class RPCEncodingTests: XCTestCase {
    
    private struct JSONRPCRequest: Codable {
        let jsonrpc: String
        let id: String
        let method: String
        let params: [AnyCodable]
    }
    
    func testCommitmentConfigEncodesInParams() throws {
        // Regression test:
        // We must encode config dictionaries as `[String: Any]` before wrapping with `AnyCodable`.
        // Using `[String: AnyCodable]` triggers `AnyEncodable value cannot be encoded`.
        let config: [String: Any] = [
            "commitment": Commitment.confirmed.rawValue
        ]
        
        let request = JSONRPCRequest(
            jsonrpc: "2.0",
            id: "1",
            method: "getLatestBlockhash",
            params: [AnyCodable(config)]
        )
        
        XCTAssertNoThrow(try JSONEncoder().encode(request))
    }
    
    func testNestedConfigEncodesInParams() throws {
        let config: [String: Any] = [
            "encoding": "base64",
            "dataSlice": [
                "offset": 0,
                "length": 32
            ],
            "minContextSlot": UInt64(123)
        ]
        
        let request = JSONRPCRequest(
            jsonrpc: "2.0",
            id: "1",
            method: "getAccountInfo",
            params: [AnyCodable("11111111111111111111111111111111"), AnyCodable(config)]
        )
        
        XCTAssertNoThrow(try JSONEncoder().encode(request))
    }
}


