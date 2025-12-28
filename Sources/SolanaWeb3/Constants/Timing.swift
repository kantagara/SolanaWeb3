//
//  Timing.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// TODO: These constants should be removed in favor of reading them out of a Syscall account.

/// The number of `tick` ledger entries per `second`.
///
/// A `tick` is a ledger entry that estimates wallclock duration.
public let numberOfTicksPerSecond: Int = 160

/// The default number of `ticks` per `slot`.
///
/// A `tick` is a ledger entry that estimates wallclock duration.
///
/// A `slot` is the period of time for which each leader ingests transactions and produces a block.
public let defaultTicksPerSlot: Int = 64

/// The number of `slots` per second.
///
/// A `slot` is the period of time for which each leader ingests transactions and produces a block.
public let numberOfSlotsPerSecond: Double = Double(numberOfTicksPerSecond) / Double(defaultTicksPerSlot)

/// The duration of a `slot` in milliseconds.
///
/// A `slot` is the period of time for which each leader ingests transactions and produces a block.
public let millisecondsPerSlot: Double = 1000.0 / numberOfSlotsPerSecond

