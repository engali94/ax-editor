/**
 *  Ax Editor
 *  Copyright (c) Ali Hilal 2020
 *  MIT license - see LICENSE.md
 */

import Foundation

public final class Row {
    public var text: String
    public var isUpdated = true
    
    public init(text: String) {
        self.text = text
    }
    
    public func render(at index: Int) -> String {
        return text//.customBackgroundColor(Defaults.backgroundColor)
    }
    
    public func length() -> Int {
        return text.count
    }
    
    func insert(char: String, at index: Int) {
        isUpdated = true
        let lowerSubstring = text[0..<index]
        let upperSubstring = text[index..<text.count]
        let newString = lowerSubstring + char + upperSubstring
        text = newString
    }
    
    func delete(at index: Int) -> String {
        guard index >= 0 && index < text.count  else { return "" }
        isUpdated = true
        var t = Array(text)
        let char = t.remove(at: index)
        text = String(t)//.remove(at: index)
        return String(char)
    }
    
    func update(text newText: String) {
        isUpdated = true
        text = newText
    }
    
    func textUpTo(index: Int) -> String {
        text.substring(toIndex: index)
    }
    
    func textFrom(index: Int) -> String {
        text.substring(fromIndex: index)
    }
    
    func renderLineNumber(_ number: Int) -> String {
        "\(number)"
            .darkGray()
            .padding(direction: .left, count: 1)
            .padding(direction: .right, count: 2)
    }
    
    func highlight(using highlighter: Highlighter) {
        //highlighter.highlight(code: text)
        isUpdated = false
    }
}

extension String {

    var length: Int {
        return count
    }

    subscript(i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    @discardableResult
    mutating func remove(at offset: Int) -> String {
        guard let index = index(startIndex, offsetBy: offset, limitedBy: endIndex) else { return self }
        remove(at: index)
        return self
    }
    
    subscript(r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
