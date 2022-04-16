//
//  Logger.swift
//  PhoneInternationaliser
//
//  Created by Ayden Panhuyzen on 2022-04-16.
//

import Foundation
import os.log

/**
 A logger that logs to system console while also publishing its messages to receivers, allowing them to be used in the UI, for example.
 - warning: Not thread safe.
 */
public class UserLogger {
    public static let shared = UserLogger()
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "UserFacing")

    private init() {}

    @inlinable public func log(_ message: String) {
        _log(message: message, level: .default)
    }

    @inlinable public func info(_ message: String) {
        _log(message: message, level: .info)
    }

    @inlinable public func debug(_ message: String) {
        _log(message: message, level: .debug)
    }

    @inlinable public func error(_ message: String) {
        _log(message: message, level: .error)
    }

    @inlinable public func fault(_ message: String) {
        _log(message: message, level: .fault)
    }

    @usableFromInline internal func _log(message: String, level: OSLogType) {
        // rip OSLog's formatting
        os_log(level, log: logger, "%{public}@", message)

        receivers.forEach { $0.didLog(message: message, level: level) }
    }

    // MARK: - Receivers

    private var _receivers = NSHashTable<AnyObject>.weakObjects() // ugh
    private var receivers: [UserLogReceiving] {
        return _receivers.allObjects as! [UserLogReceiving]
    }

    func register(receiver: UserLogReceiving) {
        _receivers.add(receiver)
    }

    func deregister(receiver: UserLogReceiving) {
        _receivers.remove(receiver)
    }
}

protocol UserLogReceiving: AnyObject {
    func didLog(message: String, level: OSLogType)
}

// MARK: - Global Functions (to make it even easier to use)

@inlinable func userLog(_ message: String) {
    UserLogger.shared.log(message)
}

@inlinable func userInfo(_ message: String) {
    UserLogger.shared.info(message)
}

@inlinable func userDebug(_ message: String) {
    UserLogger.shared.debug(message)
}

@inlinable func userError(_ message: String) {
    UserLogger.shared.error(message)
}

@inlinable func userFault(_ message: String) {
    UserLogger.shared.fault(message)
}
