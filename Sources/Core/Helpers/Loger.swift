/*
 *  Ax Editor
 *  Copyright (c) Ali Hilal 2021
 *  MIT license - see LICENSE.md
 */

import Foundation
import Logging

public struct Logger {
    
    public typealias Level = Logging.Logger.Level
    
    private static let consoleLogger = Logging.Logger(
        label: "com.alihilal.ax-editor",
        factory: StreamLogHandler.standardError
    )
    
    public static func log(
        event: Level,
        destination: Destination = .console,
        messages: Any...,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch destination {
        case .console:
            logToConsole(event: event, messages: messages, file: file, line: line)
        case .disk:
            logToDisk(event: event, messages: messages, file: file, line: line)
        }
    }
    
    private static func logToConsole(
        event: Level,
        messages: Any...,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let string = event.icon + " " + messages.map { "\($0) " }.joined()
        consoleLogger.log(level: event, .init(stringLiteral: string))
    }
    
    private static func logToDisk(
        event: Level,
        messages: Any...,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let desktopDir = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).last else { return }
        let string = event.icon + " \(Date()): " + messages.map { "\($0) " }.joined()
        try? string.write(toFile: desktopDir + "//log.txt", atomically: true, encoding: .utf8)
    }
    
    public func log(_ str: String) {
        
    }

}

public extension Logger {
    enum Destination {
        case console
        case disk
    }
}

extension Logger {
    enum Event {
        case debug
        case error
        case success
    }
}


extension Logger.Level {
    var icon: String {
        switch self {
        case .debug:
            return "⚙️"
        case .error:
            return "🚨"
        case .info:
            return "✅"
        case .trace:
            return "🔔"
        case .notice:
            return "ℹ️"
        case .warning:
            return "⚠️"
        case .critical:
            return "⛔️"
        }
    }
}
