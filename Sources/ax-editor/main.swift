import ArgumentParser
import Foundation
import Core
let rows: [Row] = [
    .init(text: "")
]
let terminal = Terminal()
let doc = Document(rows: rows)
var editor = Editor(terminal: terminal, document: doc)

//print("hahah \n\n\n\n\n\n\n code".colorize(with: .backgroundWhite), "Hahahah")
////print(Style.noStrike.code, Color.onRed.code)
//print("Reseted".colorize(with: .backgroundDefault))
//print(" ".setBackgroundColor(.backgroundCyan))
editor.run()
