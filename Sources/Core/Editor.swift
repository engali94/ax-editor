/**
 *  Ax Editor
 *  Copyright (c) Ali Hilal 2020
 *  MIT license - see LICENSE.md
 */

import Foundation
import Darwin

public final class Editor {
    private let terminal: Terminal
    private var document: Document
    private var size: Size
    private var cursorPosition: Postion
    private var quit = false
    
    public init(terminal: Terminal, document: Document) {
        self.terminal = terminal
        self.document = document
        self.size = terminal.getWindowSize()
        self.cursorPosition = .init(x: 0, y: 0)
    }
    
    public func run() {
        terminal.enableRawMode()
        write(STDIN_FILENO, "\u{1b}[?1049h", "\u{1b}[?1049h".utf8.count)
        terminal.onWindowSizeChange = { [weak self] newSize in
            self?.size = newSize
            self?.update()
        }
        
        repeat {
            update()
            readKey()
        } while (quit == false)
        exitEditor()
        write(STDIN_FILENO, "\u{1b}[?1049h", "\u{1b}[?1049l".utf8.count)
    }
    
    private func update() {
        terminal.setBackgroundColor(Defaults.backgroundColor)
        terminal.hideCursor()
        terminal.restCursor()
        terminal.clean()
        render()
        terminal.showCursor()
        terminal.flush()
        document.scrollIfNeeded(size: size)
        terminal.goto(position: .init(x: document.cursorPosition.x + 4, y: document.cursorPosition.y))
    }
    
    private func readKey() {
        while true {
            if terminal.poll(timeout: .milliseconds(16)) {
                if let event = terminal.reade() {
                    if event == .key(.init(code: .undefined)) { continue }
                    processInput(event)
                    break
                }
            }
        }
    }
    
    private func processInput(_ event: Event) {
        switch event {
        case let .key(event):
            if event.code == .backspace {
                if cursorPosition.x == 0 && cursorPosition.y != 0 {
                    document.execute(.spliceUp)
                } else if cursorPosition.x == 0 && cursorPosition.y == 0 {
                    return
                } else {
                    document.execute(.delete(position: cursorPosition))
                }
            }
            
            if let dir = mapKeyEventToDirection(event.code) {
                document.execute(.moveTo(direction: dir))
            }
            
            if event.code == .enter {
                if cursorPosition.x == 0 {
                    document.execute(.insertLineAbove(position: cursorPosition))
                } else if cursorPosition.x == document.row(atPosition: cursorPosition).length() {
                    document.execute(.insertLineBelow(position: cursorPosition))
                } else {
                    document.execute(.splitLine)
                }
            }
            if event.code == .char("d") && event.modifiers == .some(.control) {
                exitEditor()
                return
            }
            
            if event.code == .char("u") && event.modifiers == .some(.control) {
                document.undo()
                return
            }
            
            if event.code == .char("r") && event.modifiers == .some(.control) {
                document.redo()
                return
            }
            
            if case .char(let value) = event.code {
               // terminal.writeOnScreen(String(value))
                if event.modifiers == .some(.control)  { return }
                document.execute(.insert(char: String(value), position: cursorPosition))
            }
        }
    }
    
    private func mapKeyEventToDirection(_ code: KeyCode) -> Direction? {
        switch code {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        default: return nil
        }
    }
    
    private func render() {
        var frame = [""]
        let rows = size.rows
        cursorPosition = document.cursorPosition
        let offset = document.lineOffset
        for row in 0..<rows {
            if row == size.rows - 1 {
                frame.append("Command line appears here".bold())
            } else if row == size.rows - 2 {
                frame.append(
                    "Status line"
                        .yellow()
                        .bold()
                        .padding(direction: .right, count: Int(terminal.getWindowSize().cols) - "Status line".count)
                        .customBackgroundColor(.init(r: 59, g: 59, b: 84))
                )
            } else if row == size.rows / 4 && document.showsWelcome {
                frame.append(makeWelcomeMessage("Welcome to ax editor version 0.1"))
            } else if row == size.rows / 4 + 1  && document.showsWelcome {
                frame.append(makeWelcomeMessage("A Swift powered text editor by Ali Hilal"))
            } else if let line = document.row(atIndex: Int(row) + offset.y)  {
                frame.append(line.renderLineNumber(Int(row)) + document.highlight(line))
            } else {
                let tilde = "~"
                    .darkGray()
                    .padding(direction: .left, count: 1)
                frame.append(tilde)
            }
        }
        terminal
            .writeOnScreen(
                frame
                    .joined(separator: "\r\n")
                    .customBackgroundColor(Defaults.backgroundColor)
            )
    }
    
    private func makeWelcomeMessage(_ message: String) -> String {
        let paddingCount = Int(size.cols) / 2  - (message.count / 2)
        var str = ""
        let paddedMsg = message.padding(direction: .left, count: paddingCount)
        str = str
            .appending("~") // draw tilde
            .darkGray()
            .padding(direction: .left, count: 1)
            .appending(paddedMsg)
            .green()
        return str
    }
    
    private func exitEditor() {
        quit = true
        terminal.refreshScreen()
        terminal.disableRawMode()
        exit(0)
    }
}

extension String {
    enum PaddingDirection {
        case right
        case left
    }
    
    func padding(direction: PaddingDirection, count: Int) -> String {
        let padding = String(repeating: " ", count: count)
        switch direction {
        case .left:
            return padding + self
        case .right:
            return self + padding
        }
    }
}


struct Defaults {
    static let lineNoLeftPaddig   = 1 // |<-1
    static let lineNoRightPadding = 2 // 1-->...
    static let backgroundColor: Color = .init(r: 41, g: 41, b: 50)
    static let foregroundColor: Color = .init(r: 255, g: 255, b: 255)
    // line number and tilde color
    // default background color
    // default text color
    // default status line color
    // Tab width
    
}
