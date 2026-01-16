import Foundation

/// Helper for building common Solana transactions.
///
/// This lives inside the `SolanaWeb3` module so it can be reused by apps that depend on this package.
public enum SolanaTransactionBuilder {
    
    /// Creates a **versioned (v0)** SOL transfer transaction.
    ///
    /// - Parameters:
    ///   - from: The sender's public key as a base58 string.
    ///   - to: The recipient's public key as a base58 string.
    ///   - lamports: The amount to transfer in lamports (1 SOL = 1_000_000_000 lamports).
    ///   - recentBlockhash: The recent blockhash from the network.
    ///   - addressLookupTableAccounts: Optional Address Lookup Table accounts to use for v0 compilation.
    /// - Returns: A `Transaction` containing a v0 message, ready to be signed.
    public static func createVersionedTransferTransaction(
        from: String,
        to: String,
        lamports: UInt64,
        recentBlockhash: Blockhash,
        addressLookupTableAccounts: [AddressLookupTableAccount]? = nil
    ) throws -> Transaction {
        let fromPublicKey = try PublicKey.fromBase58(from)
        let toPublicKey = try PublicKey.fromBase58(to)
        
        let instruction = SystemProgram.transfer(
            fromPubkey: fromPublicKey,
            toPubkey: toPublicKey,
            lamports: lamports
        )
        
        return Transaction.v0(
            payer: fromPublicKey,
            instructions: [instruction],
            recentBlockhash: recentBlockhash,
            addressLookupTableAccounts: addressLookupTableAccounts
        )
    }
}





