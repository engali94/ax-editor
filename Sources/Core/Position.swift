//
//  Position.swift
//  ArgumentParser
//
//  Created by Ali on 14.12.2020.
//

import Foundation

struct Postion {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(_ source: [Int]) {
        precondition(source.count == 2)
        self.x = source[1]
        self.y = source[0]
    }
}
