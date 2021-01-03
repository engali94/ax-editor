//
//  Terminal.swift
//  ArgumentParser
//
//  Created by Ali on 14.12.2020.
//

import Foundation
#if os(Linux)
  import Glibc
#else
  import Darwin
#endif

public final class Terminal {
    private var originalTerminal: termios
    private let stdout: FileHandle  = .standardOutput
    private let stdin: FileHandle  = .standardInput
    private let reader: EventReader
    private let interceptor =  SignalInterceptor()
    
    public var onWindowSizeChange: ((Size) -> Void)?
    
    public init() {
        let struct_pointer = UnsafeMutablePointer<termios>.allocate(capacity: 1)
        let struct_memory = struct_pointer.pointee
        struct_pointer.deallocate()
        originalTerminal = struct_memory
        reader = EventReader(parser: EventParser())
        listenToWindowSizeChange()
    }
    
    @discardableResult
    public func enableRawMode() -> termios {
        var raw: termios = originalTerminal
        tcgetattr(stdout.fileDescriptor, &raw)

        let original = raw

        cfmakeraw(&raw)
//        raw.c_lflag &= ~(UInt(ECHO | ICANON | IEXTEN | ISIG))
//        raw.c_iflag &= ~(UInt(BRKINT | ICRNL | INPCK | ISTRIP | IXON))
//        // IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | ICRNL | IXON
//        raw.c_oflag &= ~(UInt(OPOST))
//        raw.c_cflag |= UInt((CS8))
//
//        raw.c_cc.16 = 0 // VMIN
//        raw.c_cc.17 = 1 // VTIME 1/10 = 100 ms
    
        tcsetattr(stdout.fileDescriptor, TCSAFLUSH, &raw)
        return original
    }
    
    func disableRawMode() {
        var term = originalTerminal
        tcsetattr(stdout.fileDescriptor, TCSAFLUSH, &term)
    }
    
    func poll(timeout: Timeout) -> Bool {
        reader.poll(timeout: timeout)
    }
    
    func reade() -> Event? {
        switch reader.readBuffer() {
        case .success(let event): return event
        case .failure(let error):
            print(error.localizedDescription)
            return nil
        }
    }
    
    func writeOnScreen(_ text: String) {
        let bytesCount = text.utf8.count
        write(stdout.fileDescriptor, text, bytesCount)
    }
    
    func flush() {
        fflush(__stdoutp)
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
    
    func cleanLine() {
        execute(command: .cleanLine)
    }
    
    func restCursor() {
       // execute(command: .repositionCursor)
        execute(command: .moveCursor(position: .init(x: 0, y: 0)))
    }
    
    func goto(position: Postion) {
        execute(command: .moveCursor(position: position))
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
    
    func setBackgroundColor(_ color: Color) {
        execute(command: .custom("\u{001B}[48;2;\(41);\(41);\(50)m"))
    }
    
    private func listenToWindowSizeChange() {
        interceptor.intercept {
            let newSize = self.getWindowSize()
            self.onWindowSizeChange?(newSize)
            
        }
    }
    
    private typealias WriteResult = Int
    
    @discardableResult
    private func execute(command: ANSICommand) -> WriteResult {
        // STDOUT_FILENO
        write(stdout.fileDescriptor, command.rawValue, command.bytesCount)
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
        case custom(String)

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
            case .custom(let str): return str
            }
        }
        
        var bytesCount: Int {
            rawValue.utf8.count
        }
    }
    
    enum KeyEvent {
       // case
    }
}

public struct Size {
    public let rows: UInt16
    public let cols: UInt16
}


extension Size: CustomStringConvertible {
    public var description: String {
        return "rows: \(rows), cols: \(cols)"
    }
}
