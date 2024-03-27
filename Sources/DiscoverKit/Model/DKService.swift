//
//  DKBrowser.swift
//
//
//  Created by Vinzenz Weist on 23.03.24.
//

import Foundation
import dnssd

public final class DKService: @unchecked Sendable {
    private let flags: DNSServiceFlags = .zero
    private let interface: UInt32 = .zero
    
    private var reference: DNSServiceRef? = nil
    private var queue: DispatchQueue
    
    /// Create instance for Service browser
    /// - Parameter queue: the `DispatchQueue`
    public required init(queue: DispatchQueue? = nil) {
        if let queue { self.queue = queue } else { self.queue = .init(label: .identifier, qos: .background) }
    }
    
    /// Browse for Bonjour service types
    /// - Parameters:
    ///   - type: the service type (supports also arbitrary ones)
    ///   - domain: the domain
    ///   - completion: the result as `DKServiceResult` or `Error`
    public func browse(type: String, domain: String? = nil, _ completion: @escaping (Result<DKServiceResult, Error>) -> Void) -> Void {
        let captured = Identifier { DKServiceClosure.shared.closures[$0] = nil }
        DKServiceClosure.shared.closures[captured.id] = completion
        
        /// Callback from `DNSServiceBrowse`
        let callback: DNSServiceBrowseReply = { ref, flags, interface, error, service, type, domain, context in
            guard let context, let callback = DKServiceClosure.shared.closures[context] else { return }
            var result = DKServiceResult(); result.interface = interface
            if let service { result.service = service.toString }
            if let type { result.type = type.toString }
            if let domain { result.domain = domain.toString }
            callback(.success(result))
        }
        
        /// Start Service
        DNSServiceSetDispatchQueue(reference, queue)
        let error = DNSServiceBrowse(&reference, flags, interface, type, domain, callback, captured.id)
        if error != kDNSServiceErr_NoError { completion(.failure(DKError(code: error.hashValue))); stop() }
        DNSServiceProcessResult(reference)
    }
    
    /// Stop Browsing
    public func stop() -> Void {
        DKServiceClosure.shared.reset()
        if let reference { DNSServiceRefDeallocate(reference) }
    }
}
