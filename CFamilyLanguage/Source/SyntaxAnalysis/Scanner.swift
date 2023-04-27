//
//  Scanner.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

class Scanner {
    private let source: String
    private var tokens: [Token] = []
    private var start = 0
    private var current = 0
    private var line = 1
    
    init(source: String) {
        self.source = source
    }
    
    func scanTokens() -> [Token] {
        while !isAtEnd() {
            start = current
            scanToken()
        }
        
        tokens.append(Token(type: .eof, lexeme: "", literal: nil, line: line))
        return tokens
    }
    
    private func scanToken() {
        let c = advance()
        switch c {
        case "(":
            addToken(type: .leftParen)
        case ")":
            addToken(type: .rightParen)
        case "{":
            addToken(type: .leftBrace)
        case "}":
            addToken(type: .rightBrace)
        case "[":
            addToken(type: .leftBracket)
        case "]":
            addToken(type: .rightBracket)
        case ":":
            addToken(type: .colon)
        case ",":
            addToken(type: .comma)
        case ".":
            addToken(type: .dot)
        case "-":
            addToken(type: .minus)
        case "+":
            addToken(type: .plus)
        case ";":
            addToken(type: .semicolon)
        case "*":
            addToken(type: .star)
        case "!":
            addToken(type: match("=") ? .bangEqual : .bang)
        case "=":
            addToken(type: match("=") ? .equalEqual : .equal)
        case "<":
            addToken(type: match("=") ? .lessEqual : .less)
        case ">":
            addToken(type: match("=") ? .greaterEqual : .greater)
        case "/":
            if match("/") {
                while peek() != "\n" && !isAtEnd() {
                    _ = advance()
                }
            } else {
                addToken(type: .slash)
            }
        case " ", "\r", "\t":
            break
        case "\n":
            line += 1
        case "\"":
            string()
        default:
            if isDigit(c) {
                number()
            } else if isAlpha(c) {
                identifier()
            } else {
                Language.error(line: line, message: "Unexpected character.")
            }
        }
    }
    
    private func identifier() {
        while isAlphaNumeric(peek()) {
            _ = advance()
        }
        let startIndex = source.index(source.startIndex, offsetBy: start)
        let endIndex = source.index(source.startIndex, offsetBy: current)
        let text = String(source[startIndex..<endIndex])
        var type = Scanner.keywords[text] ?? .identifier
        
        let savedPosition = current // save current index before changing it
        // If the token type is a function type, check for an opening parenthesis after the function name
        if type == .var {
            // Skip whitespace and brackets (can meet brackets in case of array declaration. ex: int[] something() {})
            while peek() == " " || peek() == "[" || peek() == "]" {
                _ = advance()
            }
            // Check if the next character is an identifier (function name)
            if isAlpha(peek()) {
                _ = advance()
                while isAlphaNumeric(peek()) {
                    _ = advance()
                }
                // Skip whitespace
                while peek() == " " {
                    _ = advance()
                }
                // Check if the next character is an opening parenthesis
                if peek() == "(" {
                    type = .fun
                }
            }
        }
        current = savedPosition
        addToken(type: type)
    }
    
    private func number() {
        while isDigit(peek()) {
            _ = advance()
        }
        
        if peek() == "." && isDigit(peekNext()) {
            _ = advance()
            while isDigit(peek()) {
                _ = advance()
            }
        }
        
        let startIndex = source.index(source.startIndex, offsetBy: start)
        let endIndex = source.index(source.startIndex, offsetBy: current)
        
        if let value = Double(source[startIndex..<endIndex]) {
            addToken(type: .number, literal: value)
        }
    }
    
    private func string() {
        while peek() != "\"" && !isAtEnd() {
            if peek() == "\n" {
                line += 1
            }
            _ = advance()
        }
        if isAtEnd() {
            Language.error(line: line, message: "Unterminated string.")
            return
        }
        
        _ = advance()
        
        let startIndex = source.index(source.startIndex, offsetBy: start + 1)
        let endIndex = source.index(source.startIndex, offsetBy: current - 1)
        
        let value = String(source[startIndex..<endIndex])
        addToken(type: .string, literal: value)
    }
    
    private func match(_ expected: Character) -> Bool {
        if isAtEnd() {
            return false
        }
        if peek() != expected {
            return false
        }
        
        current += 1
        return true
    }
    
    private func peek() -> Character {
        if isAtEnd() {
            return "\0"
        }
        return source[source.index(source.startIndex, offsetBy: current)]
    }
    
    private func peekNext() -> Character {
        if current + 1 >= source.count {
            return "\0"
        }
        return source[source.index(source.startIndex, offsetBy: current + 1)]
    }
    
    private func isAlpha(_ c: Character) -> Bool {
        return (c >= "a" && c <= "z") ||
        (c >= "A" && c <= "Z") ||
        c == "_" ||
        c == "&" ||
        c == "|"
    }
    
    private func isAlphaNumeric(_ c: Character) -> Bool {
        return isAlpha(c) || isDigit(c)
    }
    
    private func isDigit(_ c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }
    
    private func isAtEnd() -> Bool {
        return current >= source.count
    }
    
    private func advance() -> Character {
        current += 1
        return source[source.index(source.startIndex, offsetBy: current - 1)]
    }
    
    private func addToken(type: TokenType, literal: Any? = nil) {
        let startIndex = source.index(source.startIndex, offsetBy: start)
        let endIndex = source.index(source.startIndex, offsetBy: current)
        let text = String(source[startIndex..<endIndex])
        let token = Token(type: type, lexeme: text, literal: literal, line: line)
        tokens.append(token)
    }
}

// MARK: - Keywords
extension Scanner {
    private static let keywords: [String: TokenType] = [
        "&&": .and,
        "class": .class,
        "else": .else,
        "false": .false,
        "for": .for,
        "if": .if,
        "null": .nil,
        "||": .or,
        "print": .print,
        "return": .return,
        "base": .super,
        "true": .true,
        "while": .while,
        "int" : .var,
        "string": .var,
        "char": .var,
        "float": .var,
        "bool": .var,
        "void": .fun,
    ]
}
