//
//  Sysvar.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Sysvar Public Keys
/// ------------------------------------------------------------------------------------------------

/// The Clock sysvar contains data on cluster time, including the current slot, epoch, and estimated
/// wall-clock Unix timestamp. It is updated every slot.
public let sysvarClockPubkey: PublicKey = {
    return try! PublicKey.fromString("SysvarC1ock11111111111111111111111111111111")
}()

/// The EpochSchedule sysvar contains epoch scheduling constants that are set in genesis, and
/// enables calculating the number of slots in a given epoch, the epoch for a given slot, etc.
public let sysvarEpochSchedulePubkey: PublicKey = {
    return try! PublicKey.fromString("SysvarEpochSchedu1e111111111111111111111111")
}()

/// The Instructions sysvar contains the serialized instructions in a Message while that Message is
/// being processed. This allows program instructions to reference other instructions in the same
/// transaction.
public let sysvarInstructionsPubkey: PublicKey = {
    return try! PublicKey.fromString("Sysvar1nstructions1111111111111111111111111")
}()

/// The RecentBlockhashes sysvar contains the active recent blockhashes as well as their associated
/// fee calculators. It is updated every slot. Entries are ordered by descending block height, so
/// the first entry holds the most recent block hash, and the last entry holds an old block hash.
public let sysvarRecentBlockhashesPubkey: PublicKey = {
    return try! PublicKey.fromString("SysvarRecentB1ockHashes11111111111111111111")
}()

/// The Rent sysvar contains the rental rate. Currently, the rate is static and set in genesis. The
/// Rent burn percentage is modified by manual feature activation.
public let sysvarRentPubkey: PublicKey = {
    return try! PublicKey.fromString("SysvarRent111111111111111111111111111111111")
}()

public let sysvarRewardsPubkey: PublicKey = {
    return try! PublicKey.fromString("SysvarRewards111111111111111111111111111111")
}()

/// The SlotHashes sysvar contains the most recent hashes of the slot's parent banks. It is updated
/// every slot.
public let sysvarSlotHashesPubkey: PublicKey = {
    return try! PublicKey.fromString("SysvarS1otHashes111111111111111111111111111")
}()

/// The SlotHistory sysvar contains a bitvector of slots present over the last epoch. It is updated
/// every slot.
public let sysvarSlotHistoryPubkey: PublicKey = {
    return try! PublicKey.fromString("SysvarS1otHistory11111111111111111111111111")
}()

/// The StakeHistory sysvar contains the history of cluster-wide stake activations and
/// de-activations per epoch. It is updated at the start of every epoch.
public let sysvarStakeHistoryPubkey: PublicKey = {
    return try! PublicKey.fromString("SysvarStakeHistory1111111111111111111111111")
}()

