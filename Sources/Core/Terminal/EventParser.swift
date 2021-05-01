//
//  Eventparser.swift
//  Core
//

import Foundation

public struct EventParser {
    private let ESC = 27//"\u{1B}"   // Escape character (27 or 1B)
    private let SS3 = 79//"O"        // Single Shift Select of G3 charset
    private let CSI = 91//"["        // Control Sequence Introducer

    // The implementation of the parser looks ugly,
    // needs a better and swift implemenation.
    public func parse(buffer: inout [UInt8]) -> Event? {
        guard !buffer.isEmpty else { return nil }
        defer { buffer.removeAll() }
        // Possible buffer content:
        // ["ESC"] //  ctrl+ Letter
        // [ASCII] // only letter
        // [ESC, [, ASCII] // Escape sequence UP, Down, Left, Right.
        // [ESC, [, NO, NO, ~] // Escpae Sequence F5...F12.
        // [ESC, [, NO, ; , NO, ASCII] // Shift + Letter
        // [ESC, O, ASCII] // Escape Sequence F1...F4.
        while buffer.first != nil {
            let byte = buffer.removeFirst()
            if byte == NonPrintableChar.escape.rawValue {
                return .key((parseCSI(from: &buffer)))
            } else if byte == NonPrintableChar.tab.rawValue {
                return .key(.init(code: .tab))
            } else if byte == NonPrintableChar.enter.rawValue {
                return .key(.init(code: .enter))
            } else if byte == NonPrintableChar.newLine.rawValue {
                return .key(.init(code: .enter))
            } else if byte == NonPrintableChar.backspace.rawValue {
                return .key(.init(code: .backspace))
            } else if iscntrl(Int32(byte)) != 0 {
                var ascii: UInt8 = 0
                if  1...26 ~= byte {
                    ascii = (byte - 1) + 97
                } else {
                    ascii = (byte - 28) + 52
                }
                let char = Character(UnicodeScalar(ascii))
                return .key(.init(code: .char(char), modifiers: .control))
            } else {
                return .key(parseUtf8Char(from: byte))
            }
        }
        return nil
    }

    public enum NonPrintableChar: UInt8 {
        case none      = 0      //"\u{00}"   // \0 NUL
        case tab       = 9      //"\u{09}"   // \t TAB (horizontal)
        case newLine   = 10     //"\u{0A}"   // \n LF
        case enter     = 13     //"\u{0D}"   // \r CR
        case endOfLine = 26     //"\u{1A}"   // SUB or EOL
        case escape    = 27     //"\u{1B}"   // \e ESC
        case space     = 32     //"\u{20}"   // SPACE
        case backspace  = 127    //"\u{7F}"   // DEL
    }
}

private extension EventParser {

    func parseUtf8Char(from byte: UInt8 ) -> KeyEvent {
        let char = Character(UnicodeScalar(byte))
        let mod: KeyModifier = char.isUppercase ? .shift : .none
        return .init(code: .char(char), modifiers: mod)
    }

    func parseCSI(from buffer: inout [UInt8]) -> KeyEvent {
        var currentByte: UInt8 = 0
        while buffer.first != nil {
            currentByte = buffer.removeFirst()
            let remainingBytes = buffer.count
            if currentByte == CSI && remainingBytes == 1 { // [ESC, [,]
                return KeyEvent(code: mapCSINumber(buffer[0]), modifiers: nil)
            } else if currentByte == CSI && remainingBytes == 3 { //[ESC, [, NO, NO, ~]
                let str = toString(ascii: buffer[0]) + toString(ascii: buffer[1])
                guard let number = Int(str) else { return .init(code: .undefined) }
                return KeyEvent(code: mapCSINumber(UInt8(number)))
            } else if currentByte == CSI && isNumber(buffer[0]) && toString(ascii: buffer[1]) == ";" {
                // ["1", ";", "2", "B"]
                let code = mapCSINumber(buffer[3])
                let mod = isModifer(buffer[2])
                return KeyEvent(code: code, modifiers: mod)
            } else if currentByte == SS3 { // F1...4
                let number = buffer[0]
                return KeyEvent(code: mapCSINumber(number))
            } else {
                break
            }
        }
        return .init(code: .undefined)
    }

    func toString(ascii: UInt8) -> String {
        String(UnicodeScalar(ascii))
    }

    func isNumber(_ key: UInt8) -> Bool {
        return (48...57 ~= key)
    }

    func isModifer(_ key: UInt8) -> KeyModifier {
      switch key {
        case  2: return .shift          // ESC [ x ; 2~
        case  3: return .alt            // ESC [ x ; 3~
        case  5: return .control        // ESC [ x ; 5~
        default: return .none
      }
    }

    // swiftlint:disable cyclomatic_complexity
    /// Translates the ASCII code from escape sequence to its coreeosponding `KeyCode`
    /// - Parameter key: `UInt8` key to be mapped.
    /// - Returns: A key code instance.
    func mapCSINumber(_ key: UInt8) -> KeyCode {
        switch key {
            case 72: return .home        // ESC [ H  or  ESC [ 1~
            case 2: return .insert      // ESC [ 2~
            case 3: return .delete      // ESC [ 3~
            case 4: return .end         // ESC [ F  or  ESC [ 4~
            case 5: return .pageUp      // ESC [ 5~
            case 6: return .pageDown    // ESC [ 6~
            case 80: return .f(1)       // ESC O P  or  ESC [ 11~
            case 81: return .f(2)       // ESC O Q  or  ESC [ 12~
            case 82: return .f(3)       // ESC O R  or  ESC [ 13~
            case 83: return .f(4)       // ESC O S  or  ESC [ 14~
            case 15: return .f(5)       // ESC [ 15~
            case 17: return .f(6)       // ESC [ 17~
            case 18: return .f(7)       // ESC [ 18~
            case 19: return .f(8)       // ESC [ 19~
            case 20: return .f(9)       // ESC [ 20~
            case 21: return .f(10)      // ESC [ 21~
            case 23: return .f(11)      // ESC [ 23~
            case 24: return .f(12)      // ESC [ 24~
            case 65: return .up         // ESC [ A
            case 66: return .down       // ESC [ B
            case 67: return .right      // ESC [ C
            case 68: return .left       // ESC [ D
            case 90: return .backTab    // ESC [ Z
            default: return .undefined
      }
    }
}
// swiftlint:enable cyclomatic_complexity
