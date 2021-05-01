/**
 *  Ax Editor
 *  Copyright (c) Ali Hilal 2020
 *  MIT license - see LICENSE.md
 */

import Foundation

public final class Document {
    private var rows: [Row]
    private(set) var showsWelcome = false
    private(set) var lineOffset: Postion = .init(x: 0, y: 0)
    private(set) var cursorPosition: Postion = .init(x: 0, y: 0)
    private var isDirty = true
    private var undoStack = EventStack<Event>()
    private var redoStack = EventStack<Event>()
    private var language: Language? = swift
    private var tokenizer: Tokenizer = .init(language: swift)
    private var name: String = ""
    private lazy var highlighter: Highlighter? = Highlighter(tokenizer: tokenizer)

    public init(
        rows: [Row],
        name: String = "",
        language: Language? = nil
    ) {
        self.rows = rows
        self.name = name
        self.language = language
        showsWelcome = rows.isEmpty
    }

    func execute(_ event: Event, commitEvent: Bool = true) {
        isDirty = true
        func commit(_ event: Event, handler: () -> Void) {
            if event.isCommitable && commitEvent {
                redoStack.push(event)
                handler()
            }
        }
        switch event {
        case .insert(let char, let position):
            insert(character: char, at: position)
            commit(event) {
                undoStack.push(.delete(position: cursorPosition)) }
        case .delete(let position):
            let char = delete(at: position)
            commit(event) {
                undoStack.push(.insert(char: char, position: cursorPosition)) }
        case .insertLineAbove(let position):
            rows.insert(Row(text: ""), at: Int(position.y))
            moveCursor(toDirection: .down)
            commit(event) { undoStack.push(.deleteLine(position: cursorPosition, direction: .up))}
        case .insertLineBelow(let position):
            rows.insert(Row(text: ""), at: Int(position.y + 1))
            moveCursor(toDirection: .down)
            moveCursor(toPosition: .init(x: 0, y: cursorPosition.y))
            commit(event) { undoStack.push(.deleteLine(position: cursorPosition, direction: .up))}
        case .splitLine:
            splitLine()
            commit(event) { undoStack.push(.spliceUp)}
        case .spliceUp:
            spliceUp()
            commit(event) { undoStack.push(.splitLine)}
        case .deleteLine(let pos, let dir):
            deleteLine(at: pos, direction: dir)
        case .moveTo(let direction):
            moveCursor(toDirection: direction)
        }
    }

    func undo() {
        if let event = undoStack.pop() {
            execute(event, commitEvent: false)
        }
    }

    func redo() {
        if let event = redoStack.pop() {
            execute(event, commitEvent: false)
        }
    }

    func row(atPosition pos: Postion) -> Row {
        rows[pos.y]
    }

    func row(atIndex index: Int) -> Row? {
        rows[safe: index]
    }

    func scrollIfNeeded(size: Size) {
        if cursorPosition.y >= lineOffset.y + Int(size.rows) - 2 {
            lineOffset.y += 1 //cursorPosition.y - Int(size.rows) + 1
        } else {
            lineOffset.y = max(0, lineOffset.y - 1)
        }
    }

    func highlight(_ row: Row) -> String {
        return highlighter?.highlight(code: row.text) ?? row.text
    }

}

// MARK: Event
extension Document {
    enum Event {
        case insert(char: String, position: Postion)
        case delete(position: Postion)
        case insertLineAbove(position: Postion)
        case insertLineBelow(position: Postion)
        case splitLine
        case spliceUp
        case deleteLine(position: Postion, direction: Direction)
        case moveTo(direction: Direction)
    }
}

// MARK: - Private Helpers
private extension Document {
    func insert(character: String, at position: Postion) {
        showsWelcome = false
        if rows.isEmpty {
            rows.append(Row(text: character))
            moveCursor(toDirection: .right)
            return
        }
        rows[position.y].insert(char: character, at: position.x)
        moveCursor(toDirection: .right)
        //print(cursorPosition)
    }

    func delete(at position: Postion) -> String {
        let char = rows[position.y].delete(at: position.x - 1)
        moveCursor(toDirection: .left)
        return char
    }

    func moveCursor(toDirection dir: Direction) {
        switch dir {
        case .up:
            if cursorPosition.y <= 0 { return }
            cursorPosition.y -= 1
        case .down:
            if cursorPosition.y >= rows.count - 1 { return }
            cursorPosition.y += 1
        case .left:
            if cursorPosition.x <= 0 { return }
            cursorPosition.x -= 1
        case .right:
            if cursorPosition.x >= row(atPosition: cursorPosition).length() { return }
            cursorPosition.x += 1
        }
    }

    func moveCursor(toPosition pos: Postion) {
        cursorPosition = pos
    }

    func insert(row: Row, at rowIndex: Int) {
        guard rowIndex <= rows.count else { return }
        rows.insert(row, at: rowIndex)
    }

    func removeRow(at pos: Postion) {
        guard pos.y > 0 else { return }
        rows.remove(at: pos.y)
    }

    func splitLine() {
        let leftStr = row(atPosition: cursorPosition).textUpTo(index: cursorPosition.x)
        let rightStr = row(atPosition: cursorPosition).textFrom(index: cursorPosition.x)
        row(atPosition: cursorPosition).update(text: leftStr)
        insert(row: Row(text: rightStr), at: cursorPosition.y + 1)
        undoStack.push(.spliceUp) // Todo add cursor position meta data
        moveCursor(toDirection: .down)
        moveCursor(toPosition: .init(x: 0, y: cursorPosition.y))
    }

    func spliceUp() {
        guard cursorPosition.y > 0 else { return }
        let currentLine = row(atPosition: cursorPosition)
        let aboveLine = row(atPosition: .init(x: cursorPosition.x, y: cursorPosition.y - 1))
        let newRowText = aboveLine.text + currentLine.text
        aboveLine.update(text: newRowText)
        removeRow(at: cursorPosition)
        moveCursor(toPosition: .init(x: newRowText.count, y: cursorPosition.y - 1))
    }

    func deleteLine(at position: Postion, direction: Direction) {
        removeRow(at: position)
        moveCursor(toDirection: direction)
        let row = self.row(atPosition: cursorPosition) // the previous line
        moveCursor(toPosition: .init(x: row.length(), y: cursorPosition.y))
    }
}

extension Document.Event {

    var isCommitable: Bool {
        switch self {
        case .delete, .insert, .insertLineAbove, .insertLineBelow, .splitLine, .spliceUp: return true
        default: return false
        }
    }
}

struct EventStack<Event> {
    private var events = [Event]()

    var count: Int {
        events.count
    }

    mutating func push(_ event: Event) {
        events.append(event)
    }

    mutating func pop() -> Event? {
        events.popLast()
    }

    mutating func clear() {
        events.removeAll()
    }
}
