//
//  Token.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

class Token: Hashable {
    let type: TokenType
    let lexeme: String
    let literal: Any?
    let line: Int
    
    init(type: TokenType, lexeme: String, literal: Any?, line: Int) {
        self.type = type
        self.lexeme = lexeme
        self.literal = literal
        self.line = line
    }
    
    func toString() -> String {
        return "\(type) \(lexeme) \(String(describing: literal))"
    }
    
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.type == rhs.type &&
        lhs.lexeme == rhs.lexeme &&
        lhs.literal as AnyObject? === rhs.literal as AnyObject? &&
        lhs.line == rhs.line
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(lexeme)
        hasher.combine(String(describing: literal))
        hasher.combine(line)
    }
}
