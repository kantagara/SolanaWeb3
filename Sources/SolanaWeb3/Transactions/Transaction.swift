//
//  Transaction.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Transaction
public struct Transaction: Codable, Equatable {
    /// One or more signatures for the transaction. Typically created by invoking the sign method.
    public var signatures: [Data]
    
    /// One or more signatures for the transaction. Typically created by invoking the sign method.
    public let message: Message
    
    /// Transaction.
    public init(signatures: [Data]? = nil, message: Message) {
        if let signatures = signatures {
            assert(
                signatures.count == message.header.numRequiredSignatures,
                "Number of required signatures mismatch: \(message.header.numRequiredSignatures)."
            )
            self.signatures = signatures
        } else {
            // Initialize with empty signatures
            self.signatures = Array(repeating: Data(count: signatureLength), count: message.header.numRequiredSignatures)
        }
        self.message = message
    }
    
    /// The first Transaction signature (fee payer).
    public var signature: Data? {
        return signatures.isEmpty ? nil : signatures.first
    }
    
    /// The transaction/message version (`nil` == legacy).
    public var version: Int? {
        return message.version
    }
    
    /// The transaction/message blockhash.
    public var blockhash: Blockhash {
        return message.recentBlockhash
    }
    
    /// Creates a `legacy` transaction.
    public static func legacy(
        signatures: [Data]? = nil,
        payer: PublicKey,
        instructions: [TransactionInstruction],
        recentBlockhash: Blockhash
    ) -> Transaction {
        return Transaction(
            signatures: signatures,
            message: Message.legacy(
                payer: payer,
                instructions: instructions,
                recentBlockhash: recentBlockhash
            )
        )
    }
    
    /// Creates a `v0` transaction.
    public static func v0(
        signatures: [Data]? = nil,
        payer: PublicKey,
        instructions: [TransactionInstruction],
        recentBlockhash: Blockhash,
        addressLookupTableAccounts: [AddressLookupTableAccount]? = nil
    ) -> Transaction {
        return Transaction(
            signatures: signatures,
            message: Message.v0(
                payer: payer,
                instructions: instructions,
                recentBlockhash: recentBlockhash,
                addressLookupTableAccounts: addressLookupTableAccounts
            )
        )
    }
    
    /// Signs this Transaction with the specified signers.
    public mutating func sign(_ signers: [Signer]) throws {
        let serializedMessage = message.serialize()
        let numRequiredSignatures = message.header.numRequiredSignatures
        let signerPubkeys = Array(message.accountKeys.prefix(numRequiredSignatures))
        
        for signer in signers {
            guard let signerIndex = signerPubkeys.firstIndex(of: signer.pubkey) else {
                throw TransactionException("Unknown transaction signer.")
            }
            let signature = try NaClSign.shared.sign(serializedMessage, seckey: signer.seckey)
            signatures[signerIndex] = signature
        }
    }
    
    /// Serializes this transaction into a buffer.
    /// 
    /// Note: This can be called before signing. Unsigned transactions will have empty signatures (all zeros).
    /// The transaction must be signed before sending to the network.
    public func serialize() -> Data {
        let serializedTransaction = BufferWriter(2048)
        
        // Serialize the transaction message.
        let serializedMessage = message.serialize()
        
        // Write the signatures encoded length.
        let signaturesEncodedLength = encodeLength(signatures.count)
        serializedTransaction.write(signaturesEncodedLength)
        
        // Write the signatures.
        for signature in signatures {
            serializedTransaction.write(signature)
        }
        
        // Write the message.
        serializedTransaction.write(serializedMessage)
        
        return serializedTransaction.toData()
    }
    
    /// Serializes this transaction to base64 string.
    /// 
    /// Note: This can be called before signing. Unsigned transactions will have empty signatures (all zeros).
    /// The transaction must be signed before sending to the network.
    public func serializeToBase64() -> String {
        return serialize().base64EncodedString()
    }
    
    /// Serializes this transaction to base58 string.
    public func serializeToBase58() -> String {
        return Base58.encode(serialize())
    }
    
    /// Add an externally created signature to a transaction.
    public mutating func addSignature(_ pubkey: PublicKey, signature: Data) throws {
        guard signature.count == signatureLength else {
            throw TransactionException("Invalid signature length \(signature.count)")
        }
        let numRequiredSignatures = message.header.numRequiredSignatures
        let signerPubkeys = Array(message.accountKeys.prefix(numRequiredSignatures))
        guard let signerIndex = signerPubkeys.firstIndex(of: pubkey) else {
            throw TransactionException("Unknown transaction signer.")
        }
        signatures[signerIndex] = signature
    }
}

