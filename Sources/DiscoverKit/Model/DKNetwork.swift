//
//  DKNetwork.swift
//  
//
//  Created by Vinzenz Weist on 25.03.24.
//

import Foundation
import dnssd

public enum DKNetwork: DNSServiceProtocol {
    case ipv4 = 0x01
    case ipv6 = 0x02
    case udp  = 0x10
    case tcp  = 0x20
}
