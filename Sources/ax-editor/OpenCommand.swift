/**
 *  Ax Editor
 *  Copyright (c) Ali Hilal 2020
 *  MIT license - see LICENSE.md
 */

import Foundation
import ArgumentParser
import Core

public struct  OpenCommand: ParsableCommand {
    public init() {}
    @Argument(help: "The file to be edited")
    var file: String?
    
    public mutating func run() throws {
        let terminal = Terminal()
        if let file = file {
            let path = Path()
            let fullPath = try path.enumerateFullPath(from: file)
            let doc = try DocumentManager.open(from: fullPath)
            let editor = Editor(terminal: terminal, document: doc)
            editor.run()
        } else {
            let editor = Editor(terminal: terminal, document: Document(rows: []))
            editor.run()
        }
    }
}

struct Path {
    
    func enumerateFullPath(from file: String) throws -> String {
        if isValidPath(file) {
            if FileManager.default.fileExists(atPath: file) {
                return file
            } else {
                throw CocoaError.error(.fileNoSuchFile)
            }
        }
        else {
            let process = Process()
            process.arguments = ["pwd"]
            let url = URL(fileURLWithPath: "/usr/bin/env")
            
            if #available(OSX 10.13, *) {
                process.executableURL = url
            } else {
                process.launchPath = url.path
            }
            let outputPipe = Pipe()

            process.standardOutput = outputPipe
            if #available(OSX 10.13, *) {
                try process.run()
            } else {
                process.launch()
            }
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            if let str = String(data: data, encoding: .utf8) {
                let path = str.appending("/\(file)")
                    .removingAllWhitespaces
                return path
            }
            
            process.waitUntilExit()
        }
        return ""
    }
    
    private func isValidPath(_ path: String) -> Bool {
        path.starts(with: "~")  ||
        path.starts(with: "/")  ||
        path.starts(with: "./") ||
        path.starts(with: "../")
    }
}

private extension StringProtocol where Self: RangeReplaceableCollection {
    var removingAllWhitespaces: Self {
        filter { !$0.isWhitespace }
    }
}

struct DocumentManager {
    static func open(from path: String) throws -> Document {
        let name = path.split(separator: "/").last ?? ""
        let langExt = path.split(separator: ".").last ?? ""
        let lang = Config.default.languages.first(where: { $0.extensions.contains(String(langExt)) })
        print("Path", path.count)
        guard let data = FileManager.default.contents(atPath: path) else {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
             return Document(rows: [], name: String(name), language: lang)
            //throw Error.documentCouldntBeOpened
        }
        print(data.count)
        if let str = String(data: data, encoding: .utf8) {
            let rows = str.split(separator: "\n").compactMap({ Row(text:String($0)) })
            print("rows count: ", rows.count, str)
            return Document(rows: rows, name: String(name), language: lang)
        }
        return Document(rows: [], name: String(name), language: lang)
    }
    
    enum Error: Swift.Error {
        case documentCouldntBeOpened
    }
}
