import ArgumentParser
import Foundation
import Core

// STDIN_FILENO
let stdIn = FileHandle.standardInput
let terminal = Terminal()
let editor = Editor(terminal: terminal)

//editor.readKey()
editor.run()

//atexit {
//    terminal.disableRawMode()
//}
