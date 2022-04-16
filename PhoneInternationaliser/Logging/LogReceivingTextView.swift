//
//  LogReceivingTextView.swift
//  PhoneInternationaliser
//
//  Created by Ayden Panhuyzen on 2022-04-16.
//

import AppKit
import os.log

class LogReceivingTextView: NSTextView, UserLogReceiving {
    private let timeFormatter = { () -> DateFormatter in
        let f = DateFormatter()
        f.timeStyle = .medium
        f.dateStyle = .none
        return f
    }()

    func didLog(message: String, level: OSLogType) {
        let line = "\(timeFormatter.string(from: Date())) [\(level.title)]: \(message)"
        DispatchQueue.main.async {
            self.textStorage?.append(.init(string: "\(line)\n", attributes: [.font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular), .foregroundColor: level.colour]))
        }
    }
}

private extension OSLogType {
    var title: String {
        switch self {
        case .fault: return "FAULT"
        case .error: return "ERROR"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        default: return "LOG"
        }
    }

    var colour: NSColor {
        switch self {
        case .fault, .error: return .systemRed
        case .info: return .systemBlue.withSystemEffect(.deepPressed)
        default: return .textColor
        }
    }
}
