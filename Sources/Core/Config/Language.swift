/**
 *  Ax Editor
 *  Copyright (c) Ali Hilal 2020
 *  MIT license - see LICENSE.md
 */

import Foundation

public struct Language: Decodable {
    public typealias Keyword = String

    public let name: String
    public let icon: String
    public let extensions: [String]
    public let keywords: [Keyword]
    public let defentions: [Defintions]
}

public extension Language {
    typealias RegularExpression = String

    enum Defintions: Decodable {
        case comments(RegularExpression)
        case strings(RegularExpression)
        case numbers(RegularExpression)
        case types(RegularExpression)
        case functions(RegularExpression)
        case operators(RegularExpression)
        case attributes(RegularExpression)
        case dotAccess(RegularExpression)
        case properties(RegularExpression)
        case headers(RegularExpression)
        case macros(RegularExpression)
        case symbols(RegularExpression)

        public init(from decoder: Decoder) throws {
            fatalError("unimplemented")
        }
    }
}

extension Language.Defintions: CaseAccessible {
    public var regexp: String {
        associatedValue() ?? ""
    }
}

public struct Theme: Decodable {
    public typealias Highlights = TokenType

    public let backgroundColor: Color
    public let textColor: Color
    public let highlights: [Highlights: Color]
}

extension TokenType: Decodable { }

extension Theme {
    public static let vsCode = Theme(
        backgroundColor: .init(r: 40, g: 44, b: 52),
        textColor: .init(r: 171, g: 178, b: 191),
        highlights: [
            .keyword: .init(r: 16, g: 177, b: 254),
            .comment: .init(r: 99, g: 109, b: 131),
            .string: .init(r: 249, g: 200, b: 89),
            .type: .init(r: 255, g: 100, b: 128),
            .number: .init(r: 255, g: 120, b: 248),
            .property: .init(r: 206, g: 152, b: 254),
            .dotAccess: .init(r: 255, g: 147, b: 206),
            .preprocessing: .init(r: 255, g: 147, b: 106),
            .attribute: .init(r: 255, g: 147, b: 106),
            .operator: .init(r: 122, g: 130, b: 218),
            .methodCall: .init(r: 63, g: 197, b: 107)
        ])
}

public struct Color: Decodable {
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8
}

public struct Config: Decodable {
    public let tabWidth: Int
    public let theme: Theme
    public let languages: [Language]
}

extension Config {
    public static let `default` = Config(tabWidth: 4, theme: Theme.vsCode, languages: [swift])
}
