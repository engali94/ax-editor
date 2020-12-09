import ArgumentParser
import Foundation

struct Terminal {
    private var originalTerminal: termios
    private let stdout: FileHandle  = .standardOutput
    
    init() {
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
        var term = originalTerm
        tcsetattr(stdout.fileDescriptor, TCSAFLUSH, &term);
    }
    
    func writeOnScreen(_ text: String) {
        let bytesCount = text.utf8.count
        write(stdout.fileDescriptor, text, bytesCount)
    }
    
    func refreshScreen() {
        execute(command: .clean)
        restCursor()
    }
    
    func restCursor() {
        execute(command: .repositionCursor)
    }
    
    func getWindowSize() -> Size {
        var winSize = winsize()
        if (ioctl(stdout.fileDescriptor, TIOCGWINSZ, &winSize) == -1 || winSize.ws_col == 0) {
            return .init(rows: 0, cols: 0)
        } else {
            return .init(rows: winSize.ws_row, cols: winSize.ws_col)
        }
    }
    
    private func execute(command: ANSICommand) {
        // STDOUT_FILENO
        write(stdout.fileDescriptor, command.rawValue, command.bytesCount)
    }
    
    struct Size {
        let rows: UInt16
        let cols: UInt16
    }
}

extension Terminal {
    enum ANSICommand: String {
        case clean
        case repositionCursor
        case cursorPosition
        
        var rawValue: String {
            switch self {
            case .clean: return "\u{1b}[2J"
            case .repositionCursor: return "\u{1b}[H"
            case .cursorPosition: return "\u{1b}[6n"
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

struct Editor {
    
    let terminal: Terminal
    
    init(terminal: Terminal) {
        self.terminal = terminal
        drawTildes()
    }
    
    func readKey() {
        //terminal.refreshScreen()
        var char: UInt8 = 0
        while read(stdIn.fileDescriptor, &char, 1) == 1 {
            processKeypress(char)
        }
    }
    
    func processKeypress(_ char: UInt8) {
    
        if (iscntrl(Int32(char)) != 0) {
           // print("control key ", char)
        }
        
        if char == 0x04 { // detect EOF (Ctrl+D)
            exitEditor()
        }
        
        if getControlKey("q") == char {
            print("Quit the editor")
            exitEditor()
        }

        print(String(UnicodeScalar(char)) + "\r\n")
    }
    
    func drawTildes() {
        let rows = terminal.getWindowSize().rows
        for _ in 0..<rows {
            terminal.writeOnScreen("~\r\n")
        }
        terminal.restCursor()
    }
    
    private func getControlKey(_ key: String) -> UInt8 {
        let buffer = [UInt8](key.utf8)
        guard var ctrl = buffer.first else { return 0 }
        ctrl &= 0x1f
        return ctrl
    }
    
    private func exitEditor() {
        terminal.refreshScreen()
        terminal.disableRawMode()
        exit(0)
    }
}

struct Buffer {
    
}

// STDIN_FILENO
let stdIn = FileHandle.standardInput
let terminal = Terminal()
let originalTerm = terminal.enableRawMode()
let editor = Editor(terminal: terminal)
editor.readKey()
