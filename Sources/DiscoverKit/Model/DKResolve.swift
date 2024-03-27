//
//  DKResolve.swift
//
//
//  Created by Vinzenz Weist on 25.03.24.
//

import Foundation
import dnssd

public final class DKResolve: @unchecked Sendable {
    private let flags: DNSServiceFlags = .zero
    private let interface: UInt32 = .zero
    
    private var reference: DNSServiceRef? = nil
    private var queue: DispatchQueue
    
    /// Create instance for Service resolver
    /// - Parameter queue: the `DispatchQueue`
    public required init(queue: DispatchQueue? = nil) {
        if let queue { self.queue = queue } else { self.queue = .init(label: .identifier, qos: .background) }
    }
    
    /// Resolve service to host name
    /// - Parameters:
    ///   - name: the services name
    ///   - type: the service type (supports also arbitrary ones)
    ///   - domain: the domain
    ///   - completion: the result as `DKServiceResult` or `Error`
    public func resolve(name: String, type: String, domain: String? = "local.", _ completion: @escaping (Result<DKResolveResult, Error>) -> Void) -> Void {
        let captured = Identifier { DKResolveClosure.shared.closures[$0] = nil }
        DKResolveClosure.shared.closures[captured.id] = completion
        
        /// Callback from `DNSServiceResolve`
        let callback: DNSServiceResolveReply = { ref, flags, interface, error, service, host, port, length, record, context in
            guard let context, let callback = DKResolveClosure.shared.closures[context] else { return }
            var result = DKResolveResult(); result.interface = interface
            if let host { result.host = host.toString }
            result.port = UInt16(bigEndian: port)
            callback(.success(result))
        }
        
        /// Start Service
        DNSServiceSetDispatchQueue(reference, queue)
        let error = DNSServiceResolve(&reference, flags, interface, name, type, domain, callback, captured.id)
        if error != kDNSServiceErr_NoError { completion(.failure(DKError(code: error.hashValue))); stop() }
        DNSServiceProcessResult(reference)
    }
    
    /// Stop Browsing
    public func stop() -> Void {
        DKResolveClosure.shared.reset()
        if let reference { DNSServiceRefDeallocate(reference) }
    }
}
