# SolanaWeb3 Swift

A Swift implementation of Solana Web3 SDK for basic Solana operations.

This SDK provides core functionality for interacting with the Solana blockchain, including transaction serialization, keypair management, and RPC communication, it's not designed for signing & sending transactions by itself.

## Features

- Transaction serialization (legacy and v0)
- Keypair and PublicKey management
- System Program instructions
- Token Program instructions
- Associated Token Program
- RPC connection and communication
- Borsh encoding/decoding (via beet-swift)

## Installation

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-repo/solana-web3-swift", from: "1.0.0")
]
```

## Usage

```swift
import SolanaWeb3

// Create connection
let connection = Connection(.devnet)

// Create keypair
let wallet = try Keypair.generate()

// Get balance
let balance = try await connection.getBalance(wallet.pubkey)

// Create and serialize transaction
let instruction = SystemProgram.transfer(
    fromPubkey: wallet.pubkey,
    toPubkey: recipient.pubkey,
    lamports: 1_000_000
)

var transaction = Transaction.legacy(
    payer: wallet.pubkey,
    instructions: [instruction],
    recentBlockhash: blockhash.blockhash
)

// Serialize to base64
let base64 = transaction.serializeToBase64()
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
