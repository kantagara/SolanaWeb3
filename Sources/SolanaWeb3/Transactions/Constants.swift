//
//  Constants.swift
//  SolanaWeb3
//
//  Created from Dart SDK
//

import Foundation

/// Maximum over-the-wire size of a Transaction
///
/// 1280 is IPv6 minimum MTU
/// 40 bytes is the size of the IPv6 header
/// 8 bytes is the size of the fragment header
public let packetDataSize: Int = 1280 - 40 - 8

/// Version message number prefix flag.
public let versionPrefixFlag: UInt8 = 0x80

/// Version message number prefix mask.
public let versionPrefixMask: UInt8 = 0x7f

