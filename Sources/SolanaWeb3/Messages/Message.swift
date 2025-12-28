//
//  Message.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Message
public struct Message: Codable, Equatable {
    /// The transaction/message version (`nil` == legacy).
    public let version: Int?
    
    /// The account types and signatures required by the transaction.
    public let header: MessageHeader
    
    /// List of base-58 encoded public keys used by the transaction, including the instructions and
    /// signatures. The first MessageHeader.numRequiredSignatures public keys must sign the transaction.
    public let accountKeys: [PublicKey]
    
    /// A base-58 encoded hash of a recent block in the ledger used to prevent transaction
    /// duplication and to give transactions lifetimes.
    public let recentBlockhash: Blockhash
    
    /// A list of program instructions that will be executed in sequence and committed in one atomic
    /// transaction if all succeed.
    public let instructions: [MessageInstruction]
    
    /// A list of address table lookups used by a transaction to dynamically load addresses from
    /// on-chain address lookup tables.
    public let addressTableLookups: [MessageAddressTableLookup]
    
    /// Creates a the list of instructions to be processed atomically by a transaction.
    public init(
        version: Int?,
        header: MessageHeader,
        accountKeys: [PublicKey],
        recentBlockhash: Blockhash,
        instructions: [MessageInstruction],
        addressTableLookups: [MessageAddressTableLookup] = []
    ) {
        self.version = version
        self.header = header
        self.accountKeys = accountKeys
        self.recentBlockhash = recentBlockhash
        self.instructions = instructions
        self.addressTableLookups = addressTableLookups
    }
    
    /// Creates a `legacy` message.
    public static func legacy(
        payer: PublicKey,
        instructions: [TransactionInstruction],
        recentBlockhash: Blockhash
    ) -> Message {
        return compile(
            version: nil,
            payer: payer,
            instructions: instructions,
            recentBlockhash: recentBlockhash,
            addressLookupTableAccounts: nil
        )
    }
    
    /// Creates a `v0` message.
    public static func v0(
        payer: PublicKey,
        instructions: [TransactionInstruction],
        recentBlockhash: Blockhash,
        addressLookupTableAccounts: [AddressLookupTableAccount]? = nil
    ) -> Message {
        return compile(
            version: 0,
            payer: payer,
            instructions: instructions,
            recentBlockhash: recentBlockhash,
            addressLookupTableAccounts: addressLookupTableAccounts
        )
    }
    
    /// Creates a transaction message.
    public static func compile(
        version: Int?,
        payer: PublicKey,
        instructions: [TransactionInstruction],
        recentBlockhash: Blockhash,
        addressLookupTableAccounts: [AddressLookupTableAccount]?
    ) -> Message {
        // Program account keys.
        var programMetasMap = Set<PublicKey>()
        
        // Static account keys (i.e. all non address table lookup keys).
        var staticAccountMetasMap: [PublicKey: AccountMeta] = [:]
        
        // Add the fee payer account.
        staticAccountMetasMap[payer] = AccountMeta.signerAndWritable(payer)
        
        // Add the program and instruction accounts.
        for instruction in instructions {
            let programMeta = AccountMeta(instruction.programId)
            programMetasMap.insert(instruction.programId)
            if staticAccountMetasMap[instruction.programId] == nil {
                staticAccountMetasMap[instruction.programId] = programMeta
            }
            for key in instruction.keys {
                if let existingMeta = staticAccountMetasMap[key.pubkey] {
                    staticAccountMetasMap[key.pubkey] = existingMeta.copyWith(
                        isSigner: existingMeta.isSigner || key.isSigner,
                        isWritable: existingMeta.isWritable || key.isWritable
                    )
                } else {
                    staticAccountMetasMap[key.pubkey] = key
                }
            }
        }
        
        // Address table lookups.
        var addressTableLookups: [MessageAddressTableLookup] = []
        var writableLookups: [PublicKey] = []
        var readonlyLookups: [PublicKey] = []
        
        // Extract address table lookup accounts from staticAccountMetasMap.
        if let lookupAccounts = addressLookupTableAccounts {
            for lookupAccount in lookupAccounts {
                let lookupAddresses = lookupAccount.state.addresses
                var writableIndexes: [Int] = []
                var readonlyIndexes: [Int] = []
                for (i, lookupAddress) in lookupAddresses.enumerated() {
                    if let meta = staticAccountMetasMap[lookupAddress],
                       !meta.isSigner,
                       !programMetasMap.contains(meta.pubkey) {
                        assert(i < 256, "Address lookup table index \(i) exceeds the max 255.")
                        staticAccountMetasMap.removeValue(forKey: lookupAddress)
                        if meta.isWritable {
                            writableIndexes.append(i)
                            writableLookups.append(lookupAddress)
                        } else {
                            readonlyIndexes.append(i)
                            readonlyLookups.append(lookupAddress)
                        }
                    }
                }
                if !writableIndexes.isEmpty || !readonlyIndexes.isEmpty {
                    addressTableLookups.append(
                        MessageAddressTableLookup(
                            accountKey: lookupAccount.key,
                            writableIndexes: writableIndexes,
                            readonlyIndexes: readonlyIndexes
                        )
                    )
                }
            }
        }
        
        // Sort by signer accounts, followed by writable accounts.
        var staticAccountMetas = Array(staticAccountMetasMap.values)
        staticAccountMetas.sort { x, y in
            // Signers must be placed before non-signers.
            if x.isSigner != y.isSigner {
                return x.isSigner
            }
            // Writable accounts must be placed before read-only accounts.
            if x.isWritable != y.isWritable {
                return x.isWritable
            }
            return false
        }
        
        // Group the accounts.
        var writableSigners: [PublicKey] = []
        var readonlySigners: [PublicKey] = []
        var writableNonSigners: [PublicKey] = []
        var readonlyNonSigners: [PublicKey] = []
        for meta in staticAccountMetas {
            if meta.isSigner {
                if meta.isWritable {
                    writableSigners.append(meta.pubkey)
                } else {
                    readonlySigners.append(meta.pubkey)
                }
            } else {
                if meta.isWritable {
                    writableNonSigners.append(meta.pubkey)
                } else {
                    readonlyNonSigners.append(meta.pubkey)
                }
            }
        }
        
        // Create the header.
        let header = MessageHeader(
            numRequiredSignatures: writableSigners.count + readonlySigners.count,
            numReadonlySignedAccounts: readonlySigners.count,
            numReadonlyUnsignedAccounts: readonlyNonSigners.count
        )
        
        // Collect static account keys.
        let staticAccountKeys = writableSigners + readonlySigners + writableNonSigners + readonlyNonSigners
        
        // Collect all account keys.
        let accountKeys = staticAccountKeys + writableLookups + readonlyLookups
        
        // DEBUG: Check that the first account is the payer.
        assert(accountKeys.first == payer, "Missing payer.")
        
        // DEBUG: Check for duplicate accounts.
        assert(accountKeys.count == Set(accountKeys).count, "Duplicate keys.")
        
        // Create map from account key to index.
        var accountKeysMap: [PublicKey: Int] = [:]
        for (i, key) in accountKeys.enumerated() {
            accountKeysMap[key] = i
        }
        
        // Create message instructions.
        var compiledInstructions: [MessageInstruction] = []
        for instruction in instructions {
            guard let programIdIndex = accountKeysMap[instruction.programId] else {
                fatalError("Program ID not found in account keys")
            }
            let accountIndices = instruction.keys.compactMap { accountKeysMap[$0.pubkey] }
            compiledInstructions.append(
                MessageInstruction(
                    programIdIndex: programIdIndex,
                    accounts: accountIndices,
                    data: Base58.encode(instruction.data)
                )
            )
        }
        
        return Message(
            version: version,
            header: header,
            accountKeys: staticAccountKeys,
            recentBlockhash: recentBlockhash,
            instructions: compiledInstructions,
            addressTableLookups: addressTableLookups
        )
    }
    
    /// The number of account keys contained within addressTableLookups.
    public var numAccountKeysFromLookups: Int {
        return addressTableLookups.reduce(0) { total, lookup in
            total + lookup.readonlyIndexes.count + lookup.writableIndexes.count
        }
    }
    
    /// Check if the account at index is a signer account.
    public func isAccountSigner(_ index: Int) -> Bool {
        return index < header.numRequiredSignatures
    }
    
    /// Check if the account at index is a writable account.
    public func isAccountWritable(_ index: Int) -> Bool {
        if index >= accountKeys.count {
            var lookupWritableOffset = accountKeys.count
            for lookup in addressTableLookups {
                lookupWritableOffset += lookup.writableIndexes.count
                if index < lookupWritableOffset {
                    return true
                }
            }
            return false
        } else {
            return index < header.numRequiredSignatures - header.numReadonlySignedAccounts
                || (index >= header.numRequiredSignatures
                    && index < accountKeys.count - header.numReadonlyUnsignedAccounts)
        }
    }
    
    /// The programs accounts.
    public func programIds() -> [PublicKey] {
        var programIds: [PublicKey] = []
        for instruction in instructions {
            let index = instruction.programIdIndex
            programIds.append(accountKeys[index])
        }
        return programIds
    }
    
    /// The non-programs accounts.
    public func nonProgramIds() -> [PublicKey] {
        let programIds = self.programIds()
        return accountKeys.filter { !programIds.contains($0) }
    }
    
    /// Encodes this message into a buffer.
    public func serialize() -> Data {
        // Create a fixed-length writable buffer for signed data.
        let signaturesBuffer = BufferWriter(2048)
        
        // Write the version number.
        if let version = self.version {
            let maskedVersion = UInt8(versionPrefixFlag) | UInt8(version)
            signaturesBuffer.writeUInt8(maskedVersion)
        }
        
        // Write the message header.
        signaturesBuffer.writeUInt8(UInt8(header.numRequiredSignatures))
        signaturesBuffer.writeUInt8(UInt8(header.numReadonlySignedAccounts))
        signaturesBuffer.writeUInt8(UInt8(header.numReadonlyUnsignedAccounts))
        
        // Write the encoded account keys length.
        let keysLength = accountKeys.count
        signaturesBuffer.write(encodeLength(keysLength))
        
        // Write the account addresses.
        for accountKey in accountKeys {
            signaturesBuffer.write(accountKey.toBytes())
        }
        
        // Write the 32-byte blockhash (base58 decoded).
        guard let blockhashData = Base58.decode(recentBlockhash) else {
            fatalError("Message requires a valid recentBlockhash.")
        }
        assert(blockhashData.count == 32, "Blockhash must be 32 bytes")
        signaturesBuffer.write(blockhashData)
        
        // Create a fixed-length writable buffer with the maximum packet size.
        let instructionsBuffer = BufferWriter(packetDataSize)
        
        // Write the encoded instructions length.
        let ixsEncodedLength = encodeLength(instructions.count)
        instructionsBuffer.write(ixsEncodedLength)
        
        // Write the message instructions.
        for instruction in instructions {
            // Program ID index.
            instructionsBuffer.writeUInt8(UInt8(instruction.programIdIndex))
            
            // Compact array of account address indexes.
            let keyIndicesCount = encodeLength(instruction.accounts.count)
            instructionsBuffer.write(keyIndicesCount)
            let keyIndices = instruction.accounts.map { UInt8($0) }
            instructionsBuffer.write(keyIndices)
            
            // Compact array of opaque 8-bit data.
            guard let instructionData = Base58.decode(instruction.data) else {
                fatalError("Invalid instruction data")
            }
            let dataLength = encodeLength(instructionData.count)
            instructionsBuffer.write(dataLength)
            instructionsBuffer.write(instructionData)
        }
        
        // Create a fixed-length writable buffer with the maximum packet size.
        let addressTableLookupsBuffer = BufferWriter(packetDataSize)
        if version != nil {
            // Write the encoded table lookups length.
            let addressTableLookupsLength = encodeLength(addressTableLookups.count)
            addressTableLookupsBuffer.write(addressTableLookupsLength)
            
            for addressTableLookup in addressTableLookups {
                // Compact array of the writable indexes length.
                let writableIndexesCount = encodeLength(addressTableLookup.writableIndexes.count)
                
                // Compact array of the readonly indexes length.
                let readonlyIndexesCount = encodeLength(addressTableLookup.readonlyIndexes.count)
                
                addressTableLookupsBuffer.write(addressTableLookup.accountKey.toBytes())
                addressTableLookupsBuffer.write(writableIndexesCount)
                let writableIndexes = addressTableLookup.writableIndexes.map { UInt8($0) }
                addressTableLookupsBuffer.write(writableIndexes)
                addressTableLookupsBuffer.write(readonlyIndexesCount)
                let readonlyIndexes = addressTableLookup.readonlyIndexes.map { UInt8($0) }
                addressTableLookupsBuffer.write(readonlyIndexes)
            }
        }
        
        // Resize and merge the buffers.
        var result = Data()
        result.append(signaturesBuffer.toData())
        result.append(instructionsBuffer.toData())
        result.append(addressTableLookupsBuffer.toData())
        return result
    }
}
