//
//  TokenType.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

enum TokenType {
    // Single-character tokens.
    case leftParen, rightParen, leftBrace, rightBrace, leftBracket, rightBracket
    case comma, dot, minus, plus, semicolon, slash, star, colon
    
    // One or two character tokens.
    case bang, bangEqual
    case equal, equalEqual
    case greater, greaterEqual
    case less, lessEqual
    
    // Literals.
    case identifier, string, number
    
    // Keywords.
    case and, `class`, `else`, `false`, `fun`, `for`, `if`, `nil`, or
    case print, `return`, `super`, `true`, `var`, `while`
    
    // End of file.
    case eof
}
