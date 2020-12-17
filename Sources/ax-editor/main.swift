import ArgumentParser
import Foundation
import Core

let terminal = Terminal()
var editor = Editor(terminal: terminal)

editor.run()

//atexit {
//    terminal.disableRawMode()
//}
