/**
 *  Ax Editor
 *  Copyright (c) Ali Hilal 2020
 *  MIT license - see LICENSE.md
 */

import Foundation

protocol TokenGenerator {
    func tokens(from input: String) -> [Token]
}

public struct Tokenizer {
    public let language: Language
    
    func tokinze(_ code: String) -> [Token] {
        let generators = self.generators(from: code)
        return generators.flatMap { $0.tokens(from: code) }
    }
}

private extension Tokenizer {
  
    func generators(from input: String) -> [TokenGenerator] {
        var generators = [TokenGenerator]()
        let keywords = keywordGenerator(language.keywords)
        let regs = language.defentions.compactMap { regexGenerator($0.regexp, tokenType: $0.tokenType) }
        generators.append(keywords)
        generators.append(contentsOf: regs)
        return generators
    }
    
    func regexGenerator(_ pattern: String, options: NSRegularExpression.Options = [], tokenType: TokenType) -> TokenGenerator? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {  return nil }
        return RegexTokenGenerator(regularExpression: regex, tokenType: tokenType)
    }
    
    func keywordGenerator(_ words: [String]) -> TokenGenerator {
        return KeywordTokenGenerator(keywords: words)
    }

}

// MARK: Regex Token Generator
private extension Tokenizer {
    struct RegexTokenGenerator: TokenGenerator {
        private let regularExpression: NSRegularExpression
        private let tokenType: TokenType
        
        init(regularExpression: NSRegularExpression, tokenType: TokenType) {
            self.regularExpression = regularExpression
            self.tokenType = tokenType
        }
        
        func tokens(from input: String) -> [Token] {
            generateRegexTokens(source: input)
        }
        
        private func generateRegexTokens(source: String) -> [Token] {
            var tokens = [Token]()
            let fullNSRange = NSRange(location: 0, length: source.utf16.count)
            for numberMatch in regularExpression.matches(in: source, options: [], range: fullNSRange) {
                guard let swiftRange = Range(numberMatch.range, in: source) else {
                    continue
                }
                let text = String(source[swiftRange])
                let token = Token(range: swiftRange, kind: tokenType, text: text)
                tokens.append(token)
            }
            return tokens
        }
    }
}

// MARK: Keyword Token Generator
private extension Tokenizer {
    struct KeywordTokenGenerator: TokenGenerator {
        private let keywords: [String]
        
        init(keywords: [String]) {
            self.keywords = keywords
        }
        
        func tokens(from input: String) -> [Token] {
            generateKeywordTokens(source: input)
        }
      
        private func generateKeywordTokens(source: String) -> [Token] {
            var tokens = [Token]()
            source.enumerateSubstrings(in: source.startIndex..<source.endIndex, options: [.byWords]) { (word, range, _, _) in
                if let word = word, keywords.contains(word) {
                    let token = Token(range: range, kind: .keyword, text: word)
                    tokens.append(token)
                }
            }
            return tokens
        }
    }
}


extension Language.Defintions {
    public var tokenType: TokenType {
        switch self {
        case .comments: return .comment
        case .strings: return .string
        case .numbers: return .number
        case .types: return .type
        case .headers, .macros: return .preprocessing
        case .attributes: return .attribute
        case .operators, .symbols: return .operator
        case .dotAccess: return .dotAccess
        case .properties: return .property
        case .functions: return .methodCall
        //default: return .custom("undefined")
        }
    }
}

