//
//  DKError.swift
//
//
//  Created by Vinzenz Weist on 25.03.24.
//

import Foundation

public enum DKError: Error {
    case noError
    case unknown
    case noSuchName
    case noMemory
    case badParam
    case badReference
    case badState
    case badFlags
    case unsupported
    case notInitialized
    case alreadyRegistered
    case nameConflict
    case invalid
    case firewall
    case incompatible
    case badInterfaceIndex
    case refused
    case noSuchRecord
    case noAuth
    case noSuchKey
    case natTraversal
    case doubleNAT
    case badTime
    case unowned
    
    /// Map from `Int` to `Error`
    /// - Parameter code: the error code
    internal init(code: Int) {
        switch code {
        case 0: self = .noError
        case -65537: self = .unknown
        case -65538: self = .noSuchName
        case -65539: self = .noMemory
        case -65540: self = .badParam
        case -65541: self = .badReference
        case -65542: self = .badState
        case -65543: self = .badFlags
        case -65544: self = .unsupported
        case -65545: self = .notInitialized
        case -65547: self = .alreadyRegistered
        case -65548: self = .nameConflict
        case -65549: self = .invalid
        case -65550: self = .firewall
        case -65551: self = .incompatible
        case -65552: self = .badInterfaceIndex
        case -65553: self = .refused
        case -65554: self = .noSuchRecord
        case -65555: self = .noAuth
        case -65556: self = .noSuchKey
        case -65557: self = .natTraversal
        case -65558: self = .doubleNAT
        case -65559: self = .badTime
        default: self = .unowned }
    }
}

