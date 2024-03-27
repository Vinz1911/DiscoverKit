//
//  DKAddress.swift
//
//
//  Created by Vinzenz Weist on 25.03.24.
//

import Foundation
import dnssd

public final class DKAddress: @unchecked Sendable {
    private let flags: DNSServiceFlags = .zero
    private let interface: UInt32 = .zero
    
    private var reference: DNSServiceRef? = nil
    private var queue: DispatchQueue
    
    /// Create instance for Service address resolutor
    /// - Parameter queue: the `DispatchQueue`
    public required init(queue: DispatchQueue? = nil) {
        if let queue { self.queue = queue } else { self.queue = .init(label: .identifier, qos: .background) }
    }
    
    /// Get IPv4/IPv6 Address from service
    /// - Parameters:
    ///   - name: the services host name including domain e.g. APPLE-TV-4K.local.
    ///   - network: the network protocol as `DKNetwork`
    ///   - completion: the result as `DKServiceResult` or `Error`
    public func address(name: String, network: DKNetwork, _ completion: @escaping (Result<DKAddressResult, Error>) -> Void) -> Void {
        let captured = Identifier { DKAddressClosure.shared.closures[$0] = nil }
        DKAddressClosure.shared.closures[captured.id] = completion
        
        /// Callback from `DNSServiceGetAddrInfo`
        let callback: DNSServiceGetAddrInfoReply = { ref, flags, interface, error, service, address, ttl, context in
            guard let context, let callback = DKAddressClosure.shared.closures[context] else { return }
            guard let address else { callback(.failure(DKError.invalid)); return }
            
            let family = address.pointee.sa_family
            switch family {
            case UInt8(AF_INET):
                let pointer = UnsafeRawPointer(address).assumingMemoryBound(to: sockaddr_in.self)
                let ip = pointer.pointee.sin_addr
                let port = pointer.pointee.sin_port
                callback(.success(.init(ip: ip.ipv4, port: port)))
            case UInt8(AF_INET6):
                let pointer = UnsafeRawPointer(address).assumingMemoryBound(to: sockaddr_in6.self)
                let ip = pointer.pointee.sin6_addr
                let port = pointer.pointee.sin6_port
                callback(.success(.init(ip: ip.ipv6, port: port)))
            default: break }
        }
        
        /// Start Service
        DNSServiceSetDispatchQueue(reference, queue)
        let error = DNSServiceGetAddrInfo(&reference, flags, interface, network.rawValue, name, callback, captured.id)
        if error != kDNSServiceErr_NoError { completion(.failure(DKError(code: error.hashValue))); stop() }
        DNSServiceProcessResult(reference)
        DNSServiceSetDispatchQueue(reference, .main)
    }
    
    /// Stop Browsing
    public func stop() -> Void {
        DKAddressClosure.shared.reset()
        if let reference { DNSServiceRefDeallocate(reference) }
    }
}
