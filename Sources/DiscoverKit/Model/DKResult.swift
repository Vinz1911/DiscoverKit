//
//  DKResult.swift
//  
//
//  Created by Vinzenz Weist on 25.03.24.
//

import Foundation

// MARK: - Service Result -

public struct DKServiceResult: Sendable {
    public var service: String = .init()
    public var type: String = .init()
    public var domain: String = .init()
    public var interface: UInt32 = .init()
}

// MARK: - Resolve Result -

public struct DKResolveResult: Sendable {
    public var host: String = .init()
    public var port: UInt16 = .init()
    public var interface: UInt32 = .init()
}

// MARK: - Address Result -

public struct DKAddressResult: Sendable {
    public var ip: String
    public var port: UInt16
}
