//
//  Timeout.swift
//  Core

import Foundation

/// Describes the timeout ammount for listening operation.
public enum Timeout {
    /// Timeout ammount in milliseconds.
    case milliseconds(Int)

    /// Timeout ammount in seconds.
    case seconds(Int)

    /// The value of timeout measured by milliseconds.
    public var value: Int {
        switch self {
        case let .milliseconds(duration):
            return duration
        case let .seconds(duration):
            return (duration * 1000)
        }
    }

}
