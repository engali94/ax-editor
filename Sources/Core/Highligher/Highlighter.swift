/**
 *  Ax Editor
 *  Copyright (c) Ali Hilal 2020
 *  MIT license - see LICENSE.md
 */

import Foundation

public struct Highlighter {
    public let config: Config = .default
    public let tokenizer: Tokenizer

    public func highlight(code: String) -> String {
        var code = code.uncolorized()
        let tokens = tokenizer.tokinze(code)
       let log = tokens
        .map { $0.kind.rawValue + " \($0.range.lowerBound) \($0.range.upperBound)" }
        .joined(separator: " ")
        Logger.log(event: .debug, destination: .disk, messages: log)
        tokens.forEach { token in
            let color = self.color(for: token.kind)
            code.highlight(token.text, with: color, at: token.range)
        }
        
        Logger.log(event: .debug, destination: .disk, messages: code)
        return code
    }
}

private extension Highlighter {
    func color(for token: TokenType) -> Color {
        config.theme.highlights[token] ?? Color(r: 250, g: 141, b: 87)
    }
}

extension String {
    mutating func highlight(_ word: String, with color: Color, at range: Range<String.Index>) {
        //let word = String(self[range])
        //word = word.customForegroundColor(color)//"\u{001B}[38;2;\(color.r);\(color.g);\(color.b)m" + word +  TerminalStyle.reset.open
        self = replacingOccurrences(of: word, with: word.customForegroundColor(color))
    }
}
