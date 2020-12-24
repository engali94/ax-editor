//
//  Editor.swift
//  ArgumentParser
//
//  Created by Ali on 14.12.2020.
//

import Foundation
import Darwin

public final class Editor {
    
    private var terminal: Terminal
    private var size: Size
    private var cursorPosition: Postion
    private var quit = false
    
    public init(terminal: Terminal) {
        self.terminal = terminal
        self.size = terminal.getWindowSize()
        self.cursorPosition = .init([1,2])//terminal.cursorPosition()
    }
    
    public func run() {
        terminal.enableRawMode()
        //drawTildes()
        terminal.onWindowSizeChange = { [weak self] newSize in
            print("Termial resized", newSize)
            self?.size = newSize
        }
        
        repeat {
            update()
            handleInput()
        } while (quit == false)
        exitEditor()
    }
    
    private func update() {
        terminal.hideCursor()
        terminal.restCursor()
        //render()
        terminal.goto(position: .init(x: cursorPosition.x + 1, y: cursorPosition.y + 1))
        terminal.restCursor()
    }
    
    private func handleInput() {
        let key = readKey()
        processKeypress(key)
    }
    
    private func readKey() -> UInt8 {
        // TODO: This should read from terminal not.
        // From the stdin directly.
        if terminal.poll(timeout: .milliseconds(16)) {
            print("\n\n\n\nInput avalilabel")
//            var char: UInt8 = 0
//            read(STDIN_FILENO, &char, 1) //!= 1 { }
//            return char
            terminal.reade()
        }
        
       return 0
    }
    
    private func processKeypress(_ char: UInt8) {
        if (iscntrl(Int32(char)) != 0) {
           // print("control key ", char)
        }
        
        if char == 0x04 { // detect EOF (Ctrl+D)
            exitEditor()
        }
        
        if getControlKey("q") == char {
            print("Quit the editor")
            exitEditor()
            quit = true
        }
        // print(terminal.cursorPosition())
        print(String(UnicodeScalar(char)))
        terminal.writeOnScreen(String(UnicodeScalar(char)) + "\r\n")
    }
    
    private func render() {
        drawTildes()
    }
    
    
    private func drawTildes() {
        var str = ""
        let rows = terminal.getWindowSize().rows
        for row in 0..<rows {
            if row == rows / 3 {
                let message = "Welcome to ax editor version 0.1"
                var padding = (Int(terminal.getWindowSize().cols) - message.count) / 2
                     if (padding > 0) {
                        str.append("~")
                        padding -= 1
                }
                while padding > 0 {
                    str.append(" ")
                    padding -= 1
                }
                str.append(message)
            } else {
                str.append("~")
            }
            
            str.append("\u{1b}[K")
 
            if row < rows - 1 {
                str.append("\r\n")
               // terminal.cleanLine()
            }
        }
        terminal.writeOnScreen(str)
       // showWelcomeMessage()
    }
//
//    private func showWelcomeMessage() {
//        let rows = terminal.getWindowSize().rows
//        for row in 0..<rows {
//            if row == 10 {
//                let message = "Welcome to ax editor version 0.1"
//                terminal.print(message)
//            }
//
//            if row == 15 {
//                let message = "by Ali Hilal @engali94"
//                terminal.print(message)
//            }
//        }
//    }
    
    private func getControlKey(_ key: String) -> UInt8 {
        let buffer = [UInt8](key.utf8)
        guard var ctrl = buffer.first else { return 0 }
        ctrl &= 0x1F
        return ctrl
    }
    
    private func exitEditor() {
        //quit = true
        terminal.refreshScreen()
        terminal.disableRawMode()
        exit(0)
    }
}

extension Editor {
    enum Key {
        case char(UInt8)
        case up
        case down
        case left
        case right
    }
    
    enum Event {
        case backspace
    }
    
    // KeyBinding
    enum ControlKey {
        case ctrl(key: Key)
        case alt(key: Key)
        case shift(key: Key)
    }
//    // Keys without modifiers
//      enum Key {
//        Char(char),
//        Up,
//        Down,
//        Left,
//        Right,
//        Backspace,
//        Enter,
//        Tab,
//        Home,
//        End,
//        PageUp,
//        PageDown,
//        BackTab,
//        Delete,
//        Insert,
//        Null,
//        Esc,
//    }
    
//    bitflags! {
//        /// Represents key modifiers (shift, control, alt).
//        #[cfg_attr(feature = "serde", derive(Serialize, Deserialize))]
//        pub struct KeyModifiers: u8 {
//            const SHIFT = 0b0000_0001;
//            const CONTROL = 0b0000_0010;
//            const ALT = 0b0000_0100;
//            const NONE = 0b0000_0000;
//        }
//    }
}

struct Document {
    
}
