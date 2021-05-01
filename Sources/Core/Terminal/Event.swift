//
//  Event.swift
//  Core
//
//  Created by Ali on 24.12.2020.
//

import Foundation

public enum Event: Equatable {
    case key(KeyEvent)
   //case resize
   //case mouse
}

extension Event: CustomStringConvertible {
    public var description: String {
        switch self {
        case .key(let event):
            return String(describing: event)
        }
    }
}

public enum KeyModifier: UInt8, Equatable {
    case control  = 1
    case shift    = 2
    case alt      = 3
    case none     = 0
}

extension KeyModifier: CustomStringConvertible {
    public var description: String {
        switch self {
        case .alt: return "Alt"
        case .control: return "Control"
        case .shift: return "Shift"
        case .none: return "None"
        }
    }
}

public struct KeyEvent: Equatable {
    /// The key itself.
    public let code: KeyCode
    /// Additional key modifiers.
    public let modifiers: KeyModifier?

    public init(code: KeyCode, modifiers: KeyModifier? = nil) {
        self.code = code
        self.modifiers = modifiers
    }
}

extension KeyEvent: CustomStringConvertible {
    public var description: String {
        return "code: \(code), mods: \(modifiers ?? .none)"
    }
}

/// A type that represents a key.
public enum KeyCode: Equatable {
    /// Undefined.
    case undefined
    /// Backspace key.
    case backspace
    /// Enter key.
    case enter
    /// Left arrow key.
    case left
    /// Right arrow key.
    case right
    /// Up arrow key.
    case up
    /// Down arrow key.
    case down
    /// Home key.
    case home
    /// End key.
    case end
    /// Page up key.
    case pageUp
    /// Page dow key.
    case pageDown
    /// Tab key.
    case tab
    /// Shift + Tab key.
    case backTab
    /// Delete key.
    case delete
    /// Insert key.
    case insert
    /// F(x) key.
    case f(UInt8)
    /// A character.
    case char(Character)
    /// Escape key.
    case esc

}
