//
//  Extensions.swift
//
//
//  Created by Vinzenz Weist on 23.03.24.
//

import Foundation

// MARK: - Identifier -

internal extension String {
    /// identifier name
    static var identifier: Self {
        return "DiscoverKit.\(UUID().uuidString)"
    }
}

// MARK: - Pointer Helper -

internal final class Identifier {
    internal let id = UnsafeMutableRawPointer.allocate(byteCount: .zero, alignment: .zero)
    private let pointer: (UnsafeMutableRawPointer) -> Void
    
    /// Initialize identifier capture for `UnsafeMutableRawPointer`
    /// - Parameter pointer: callback which is invoked on deinit
    required init(_ pointer: @escaping (UnsafeMutableRawPointer) -> Void) { self.pointer = pointer }
    
    /// Invoke `UnsafeMutableRawPointer` deallocation
    deinit { pointer(id); id.deallocate() }
}

// MARK: - Unsafe Pointer -

internal extension UnsafePointer<CChar> {
    /// Safely unwraps a `UnsafePointer` from type ``CChar``
    var toString: String { .init(cString: self, encoding: .utf8) ?? .init() }
}

internal extension in_addr {
    /// Get IPv4 as string
    var ipv4: String {
        guard let cString = inet_ntoa(self) else { return .init() }
        return String(cString: cString)
    }
}

internal extension in6_addr {
    /// Get IPv6 as string
    var ipv6: String {
        var buffer = [Int8](repeating: 0, count: Int(INET6_ADDRSTRLEN)); var addr = self
        guard let cString = inet_ntop(AF_INET6, &addr, &buffer, socklen_t(INET6_ADDRSTRLEN)) else { return .init() }
        return String(cString: cString)
    }
}

// MARK: - Captured Closures -

internal class DKResolveClosure: @unchecked Sendable {
    internal static let shared = DKResolveClosure()
    internal var closures: [UnsafeMutableRawPointer: (Result<DKResolveResult, Error>) -> Void] = [:]
    internal func reset() -> Void { closures.removeAll() }
}

internal class DKAddressClosure: @unchecked Sendable {
    internal static let shared = DKAddressClosure()
    internal var closures: [UnsafeMutableRawPointer: (Result<DKAddressResult, Error>) -> Void] = [:]
    internal func reset() -> Void { closures.removeAll() }
}

internal class DKServiceClosure: @unchecked Sendable {
    internal static let shared = DKServiceClosure()
    internal var closures: [UnsafeMutableRawPointer: (Result<DKServiceResult, Error>) -> Void] = [:]
    internal func reset() -> Void { closures.removeAll() }
}
