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
    private var size: Terminal.Size
    private var cursorPosition: Postion
    private var quit = false
    
    public init(terminal: Terminal) {
        self.terminal = terminal
        self.size = terminal.getWindowSize()
        self.cursorPosition = terminal.cursorPosition()
    }
    
    public mutating func run() {
        terminal.enableRawMode()
        terminal.refreshScreen()
        //drawTildes()
        repeat {
            update()
            handleInput()
        } while (quit == false)
        exitEditor()
    }
    
    private mutating func update() {
        print(#function)
        // 1. Adjust the terminal behaviour before rendering.
        //terminal.clean()
        terminal.hideCursor()
        terminal.restCursor()
        // 2. render
        render()
        // 3. Adjust the terminal behaviour after the rendering.
        //terminal.goto(position: .init(x: 0, y: 0))
        terminal.restCursor()
    }
    
    private mutating func handleInput() {
        let key = readKey()
        //if  key != 0 {
            processKeypress(key)
       // }
    }
    
    private mutating func readKey() -> UInt8 {
        var char: UInt8 = 0
        while read(STDIN_FILENO, &char, 1) != 1 { }
        return char
    }
    
    private mutating func processKeypress(_ char: UInt8) {
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
        terminal.print(String(UnicodeScalar(char)) + "\r\n")
    }
    
    private func render() {
        drawTildes()
    }
    
    private func drawTildes() {
        let rows = terminal.getWindowSize().rows
        var str = ""
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
        terminal.print(str)
       // showWelcomeMessage()
    }

    private func showWelcomeMessage() {
        let rows = terminal.getWindowSize().rows
        for row in 0..<rows {
            if row == 10 {
                let message = "Welcome to ax editor version 0.1"
                terminal.print(message)
            }
            
            if row == 15 {
                let message = "by Ali Hilal @engali94"
                terminal.print(message)
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
        //quit = true
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
