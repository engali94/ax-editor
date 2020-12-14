//
//  Editor.swift
//  ArgumentParser
//
//  Created by Ali on 14.12.2020.
//

import Foundation
import Darwin

public struct Editor {
    
    private let terminal: Terminal
    private var quit = false
    
    public init(terminal: Terminal) {
        self.terminal = terminal
    }
    
    public func run() {
        terminal.enableRawMode()
        repeat {
            update()
            handleInput()
        } while (quit == false)
        exitEditor()
    }
    
    private func update() {
        // 1. Adjust the terminal behaviour before rendering.
        terminal.hideCursor()
        terminal.restCursor()
        // 2. render
        render()
        // 3. Adjust the terminal behaviour after the rendering.
        terminal.goto(position: .init(x: 0, y: 0))
        terminal.showCursor()
    }
    
    private func handleInput() {
        let key = readKey()
        processKeypress(key)
    }
    
    private func readKey() -> UInt8 {
        var char: UInt8 = 0
        while read(STDIN_FILENO, &char, 1) == 1 {
            return char
        }
        return char
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
        }

       // print(terminal.cursorPosition())
        print(String(UnicodeScalar(char)) + "\r\n")
    }
    
    private func render() {
        
    }
    
    private func drawTildes() {
        let rows = terminal.getWindowSize().rows
        terminal.refreshScreen()
        terminal.hideCursor()
        for row in 0..<rows {
            terminal.writeOnScreen("~")
            if row < rows - 1 {
                terminal.writeOnScreen("\r\n")
            }
        }
        terminal.showCursor()
        terminal.restCursor()
        showWelcomeMessage()
    }

    private func showWelcomeMessage() {
        let rows = terminal.getWindowSize().rows
        for row in 0..<rows {
            if row == 10 {
                let message = "Welcome to ax editor version 0.1"
                terminal.writeOnScreen(message)
            }
            
            if row == 15 {
                let message = "by Ali Hilal @engali94"
                terminal.writeOnScreen(message)
            }
        }
    }
    
    private func getControlKey(_ key: String) -> UInt8 {
        let buffer = [UInt8](key.utf8)
        guard var ctrl = buffer.first else { return 0 }
        ctrl &= 0x1F
        return ctrl
    }
    
    private func exitEditor() {
        terminal.refreshScreen()
        terminal.disableRawMode()
        exit(0)
    }
}

extension Editor {
    enum Key {
        case char(UInt8)
    }
    
    enum Event {
        case backspace
    }
}

struct Document {
    
}
