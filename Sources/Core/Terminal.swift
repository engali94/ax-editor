//
//  Terminal.swift
//  ArgumentParser
//
//  Created by Ali on 14.12.2020.
//

import Foundation
import Darwin

public struct Terminal {
    private var originalTerminal: termios
    private let stdout: FileHandle  = .standardOutput
    private let stdin: FileHandle  = .standardInput
    
    public init() {
        let struct_pointer = UnsafeMutablePointer<termios>.allocate(capacity: 1)
        let struct_memory = struct_pointer.pointee
        struct_pointer.deallocate()
        originalTerminal = struct_memory
    }
    
    @discardableResult
    func enableRawMode() -> termios {
        var raw: termios = originalTerminal
        tcgetattr(stdout.fileDescriptor, &raw)

        let original = raw

        raw.c_lflag &= ~(UInt(ECHO | ICANON | IEXTEN | ISIG))
        raw.c_iflag &= ~(UInt(ICRNL | IXON))
        raw.c_oflag &= ~(UInt(OPOST))
        
        tcsetattr(stdout.fileDescriptor, TCSAFLUSH, &raw)

        return original
    }
    
    func disableRawMode() {
        var term = originalTerminal
        tcsetattr(stdout.fileDescriptor, TCSAFLUSH, &term);
    }
    
    func writeOnScreen(_ text: String) {
        let bytesCount = text.utf8.count
        write(stdout.fileDescriptor, text, bytesCount)
    }
    
    func refreshScreen() {
        hideCursor()
        clean()
        restCursor()
        showCursor()
    }
    
    func clean() {
        execute(command: .clean)
    }
    
    func restCursor() {
        execute(command: .repositionCursor)
    }
    
    func goto(position: Postion) {
        
    }
    
    func cursorPosition() -> Postion {
        // https://vt100.net/docs/vt100-ug/chapter3.html#CPR
        guard execute(command: .cursorCurrentPosition) == 4 else { return .init(x: 0, y: 0) }
        var c: UInt8 = 0
        var response: [UInt8] = []
        
        repeat {
            read(STDIN_FILENO, &c, 1)
            response.append(c)
        } while c != UInt8(ascii: "R")
        
        let result = response
            .map({ String(UnicodeScalar($0)) })
            .compactMap(Int.init)
            
        return .init(result)
    }
    
    func getWindowSize() -> Size {
        var winSize = winsize()
        if (ioctl(stdout.fileDescriptor, TIOCGWINSZ, &winSize) == -1 || winSize.ws_col == 0) {
            return .init(rows: 0, cols: 0)
        } else {
            return .init(rows: winSize.ws_row, cols: winSize.ws_col)
        }
    }
    
    func hideCursor() {
        execute(command: .hideCursor)
    }
    
    func showCursor() {
        execute(command: .showCursor)
    }
    
    private typealias WriteResult = Int
    
    @discardableResult
    private func execute(command: ANSICommand) -> WriteResult {
        // STDOUT_FILENO
        write(stdout.fileDescriptor, command.rawValue, command.bytesCount)
    }
    
    struct Size {
        let rows: UInt16
        let cols: UInt16
    }

}

extension Terminal {
    enum ANSICommand {
        case clean
        case cleanLine
        case repositionCursor
        case cursorCurrentPosition
        case showCursor
        case hideCursor
        case moveCursor(position: Postion)
        
        var rawValue: String {
            switch self {
            case .clean: return "\u{1b}[2J"
            case .cleanLine: return "\u{1b}[K"
            case .repositionCursor: return "\u{1b}[H"
            case .cursorCurrentPosition: return "\u{1b}[6n"
            case .showCursor: return "\u{1b}[?25h"
            case .hideCursor: return "\u{1b}[?25l"
            case let .moveCursor(position):
                return "\u{1b}[\(position.y + 1);\(position.x + 1)H"
            }
        }
        
        var bytesCount: Int {
            rawValue.utf8.count
        }
    }
}


extension Terminal.Size: CustomStringConvertible {
    var description: String {
        return "rows: \(rows), cols: \(cols)"
    }
}
