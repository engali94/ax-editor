//
//  Token.swift
//  Core
//
//  Created by Ali on 1.01.2021.
//

import Foundation

public struct Token {
    /// The range of the token in the source string.
    public let range: Range<String.Index>
    public let kind: TokenType
    public let text: String
}

public enum TokenType: String {
    /// A language keyword
    case keyword
    /// A string literal
    case string
    /// A reference to a type
    case type
    /// A number, either interger of floating point
    case number
    /// A comment, either single or multi-line
    case comment
    /// A property being accessed, such as `object.property`
    case property
    /// A symbol being accessed through dot notation, such as `.myCase`
    case dotAccess
    /// A preprocessing symbol, such as `#if`, `#define` etc.
    case preprocessing
    /// An attribute symbol like `@objc`
    case attribute
    /// A special operator like `&&`, `||` etc.
    case `operator`
    /// like myMethod()
    case methodCall
}

extension TokenType {
    /// Return a string value representing the token type
    public var string: String {
        if case .`operator` = self {
            return "operator"
        }
        return "\(self)"
    }
}

