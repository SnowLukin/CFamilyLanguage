//
//  Parser.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

class Parser {
    private class ParseError: Error {}
    private let tokens: [Token]
    private var current = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parse() throws -> [Stmt] {
        var statements: [Stmt] = []
        while !isAtEnd() {
            if let declaration = try declaration() {
                statements.append(declaration)
            }
        }
        return statements
    }
    
    private func checkType(_ typeTokenString: String) throws -> String {
        var typeTokenString = typeTokenString
        // check if function type is array
        let savedPosition = current
        if !isAtEnd(), advance().type == .leftBracket {
            _ = try consume(type: .rightBracket, message: "Expect ']' in array type declaration.")
            typeTokenString += "[]" // ex: int[]
        } else {
            current = savedPosition
        }
        return typeTokenString
    }
    
    private func match(types: TokenType...) -> Bool {
        for type in types {
            if check(type: type) {
                _ = advance()
                return true
            }
        }
        return false
    }

    private func consume(type: TokenType, message: String) throws -> Token {
        if check(type: type) {
            return advance()
        }
        throw error(at: peek(), message: message)
    }

    private func check(type: TokenType) -> Bool {
        if isAtEnd() { return false }
        return peek().type == type
    }

    private func advance() -> Token {
        if !isAtEnd() { current += 1 }
        return previous()
    }

    private func isAtEnd() -> Bool {
        return peek().type == .eof
    }

    private func peek() -> Token {
        return tokens[current]
    }

    private func previous() -> Token {
        return tokens[current - 1]
    }

    private func error(at token: Token, message: String) -> ParseError {
        Language.error(token: token, message: message)
        return ParseError()
    }

    private func synchronize() {
        _ = advance()
        while !isAtEnd() {
            if previous().type == .semicolon { return }
            switch peek().type {
            case .class, .fun, .var, .for, .if, .while, .print, .return:
                return
            default:
                _ = advance()
            }
        }
    }
}

// MARK: - Node creating
extension Parser {
    private func expression() throws -> Expr {
        return try assignment()
    }
    
    private func declaration() throws -> Stmt? {
        do {
            if match(types: .class) { return try classDeclaration() }
            if check(type: .fun) { return try function(kind: "function") }
            if check(type: .var) { return try varDeclaration() }
            return try statement()
        } catch is ParseError {
            synchronize()
            return nil
        }
    }
    
    private func classDeclaration() throws -> Stmt {
        let name = try consume(type: .identifier, message: "Expect class name.")
        var superclass: Expr.Variable? = nil
        if match(types: .colon) {
            _ = try consume(type: .identifier, message: "Expect superclass name.")
            superclass = Expr.Variable(name: previous())
        }
        _ = try consume(type: .leftBrace, message: "Expect '{' before class body.")
        
        var methods: [Stmt.Function] = []
        while !check(type: .rightBrace) && !isAtEnd() {
            methods.append(try function(kind: "method"))
        }
        
        try _ = consume(type: .rightBrace, message: "Expect '}' after class body.")
        return Stmt.Class(name: name, superclass: superclass, methods: methods)
    }
    
    private func statement() throws -> Stmt {
        if match(types: .for) { return try forStatement() }
        if match(types: .if) { return try ifStatement() }
        if match(types: .print) { return try printStatement() }
        if match(types: .return) { return try returnStatement() }
        if match(types: .while) { return try whileStatement() }
        if match(types: .leftBrace) { return Stmt.Block(statements: try block()) }
        return try expressionStatement()
    }
    
    private func forStatement() throws -> Stmt {
        try _ = consume(type: .leftParen, message: "Expect '(' after 'for'.")
        
        let initializer: Stmt?
        if match(types: .semicolon) {
            initializer = nil
        } else if check(type: .var) {
            initializer = try varDeclaration()
        } else {
            initializer = try expressionStatement()
        }
        
        var condition: Expr? = nil
        if !check(type: .semicolon) {
            condition = try expression()
        }
        try _ = consume(type: .semicolon, message: "Expect ';' after loop condition.")
        
        var increment: Expr? = nil
        if !check(type: .rightParen) {
            increment = try expression()
        }
        try _ = consume(type: .rightParen, message: "Expect ')' after for clauses.")
        
        var body = try statement()
        if let increment = increment {
            body = Stmt.Block(statements: [
                body,
                Stmt.Expression(expression: increment)
            ])
        }
        
        if condition == nil { condition = Expr.Literal(value: true) }
        body = Stmt.While(condition: condition!, body: body)
        
        if let initializer = initializer {
            body = Stmt.Block(statements: [initializer, body])
        }
        return body
    }
    
    private func ifStatement() throws -> Stmt {
        try _ = consume(type: .leftParen, message: "Expect '(' after 'if'.")
        let condition = try expression()
        try _ = consume(type: .rightParen, message: "Expect ')' after if condition.")
        
        let thenBranch = try statement()
        var elseBranch: Stmt? = nil
        
        if match(types: .else) {
            elseBranch = try statement()
        }
        
        return Stmt.If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch)
    }
    
    private func printStatement() throws -> Stmt {
        let value = try expression()
        _ = try consume(type: .semicolon, message: "Expect ';' after value.")
        return Stmt.Print(expression: value)
    }
    
    private func returnStatement() throws -> Stmt {
        let keyword = previous()
        var value: Expr? = nil
        
        if !check(type: .semicolon) {
            value = try expression()
        }
        
        _ = try consume(type: .semicolon, message: "Expect ';' after return value.")
        return Stmt.Return(keyword: keyword, value: value)
    }
    
    private func varDeclaration() throws -> Stmt {
        let typeToken = try consume(type: .var, message: "Expect variable type modifier.")
        let typeLexeme = try checkType(typeToken.lexeme)
        let type = CType.getType(from: typeLexeme)
        guard type != .none else {
            throw error(at: typeToken, message: "Unexpected variable type modifier.")
        }
        
        let name = try consume(type: .identifier, message: "Expect variable name.")
        var initializer: Expr? = nil
        
        if match(types: .equal) {
            initializer = try expression()
        }
        
        _ = try consume(type: .semicolon, message: "Expect ';' after variable declaration.")
        return Stmt.Var(name: name, type: type, initializer: initializer)
    }
    
    private func whileStatement() throws -> Stmt {
        _ = try consume(type: .leftParen, message: "Expect '(' after 'while'.")
        let condition = try expression()
        _ = try consume(type: .rightParen, message: "Expect ')' after condition.")
        let body = try statement()
        
        return Stmt.While(condition: condition, body: body)
    }
    
    private func expressionStatement() throws -> Stmt {
        let expr = try expression()
        _ = try consume(type: .semicolon, message: "Expect ';' after expression.")
        return Stmt.Expression(expression: expr)
    }
    
    private func function(kind: String) throws -> Stmt.Function {
        let typeToken = try consume(type: .fun, message: "Expect \(kind) modifier.")
        let typeLexeme = try checkType(typeToken.lexeme)
        let type = CType.getType(from: typeLexeme)
        guard type != .none else {
            throw error(at: typeToken, message: "Unexpected \(kind) modifier.")
        }
        let name = try consume(type: .identifier, message: "Expect \(kind) name.")
        _ = try consume(type: .leftParen, message: "Expect '(' after \(kind) name.")
        
        var parameters: [Stmt.Var] = []
        if !check(type: .rightParen) {
            repeat {
                if parameters.count >= 255 {
                    _ = error(at: peek(), message: "Can't have more than 255 parameters.")
                }
                let type = try consume(type: .var, message: "Expect parameter type.")
                let identifier = try consume(type: .identifier, message: "Expect parameter name.")
                parameters.append(Stmt.Var(name: identifier, type: CType.getType(from: type.lexeme), initializer: nil))
            } while match(types: .comma)
        }
        
        _ = try consume(type: .rightParen, message: "Expect ')' after parameters.")
        _ = try consume(type: .leftBrace, message: "Expect '{' before \(kind) body.")
        
        let body = try block()
        return Stmt.Function(name: name, type: type, params: parameters, body: body)
    }
    
    private func block() throws -> [Stmt] {
        var statements: [Stmt] = []
        
        while !check(type: .rightBrace) && !isAtEnd() {
            if let decl = try declaration() {
                statements.append(decl)
            }
        }
        
        _ = try consume(type: .rightBrace, message: "Expect '}' after block.")
        return statements
    }
    
    private func assignment() throws -> Expr {
        let expr = try or()
        
        if match(types: .equal) {
            let equals = previous()
            let value = try assignment()
            
            if let variable = expr as? Expr.Variable {
                let name = variable.name
                return Expr.Assign(name: name, value: value)
            }
            if let get = expr as? Expr.Get {
                return Expr.Set(object: get.object, name: get.name, value: value)
            }
            if let subs = expr as? Expr.Subscript {
                return Expr.Subscript(name: subs.name, index: subs.index, value: value, paren: subs.paren)
            }
            
            _ = error(at: equals, message: "Invalid assignment target.")
        }
        
        return expr
    }
    
    private func or() throws -> Expr {
        var expr = try and()
        
        while match(types: .or) {
            let `operator` = previous()
            let right = try and()
            expr = Expr.Logical(left: expr, operator: `operator`, right: right)
        }
        
        return expr
    }
    
    private func and() throws -> Expr {
        var expr = try equality()
        
        while match(types: .and) {
            let `operator` = previous()
            let right = try equality()
            expr = Expr.Logical(left: expr, operator: `operator`, right: right)
        }
        
        return expr
    }
    
    private func equality() throws -> Expr {
        var expr = try comparison()

        while match(types: .bangEqual, .equalEqual) {
            let `operator` = previous()
            let right = try comparison()
            expr = Expr.Binary(left: expr, operator: `operator`, right: right)
        }

        return expr
    }

    private func comparison() throws -> Expr {
        var expr = try term()

        while match(types: .greater, .greaterEqual, .less, .lessEqual) {
            let `operator` = previous()
            let right = try term()
            expr = Expr.Binary(left: expr, operator: `operator`, right: right)
        }

        return expr
    }

    private func term() throws -> Expr {
        var expr = try factor()

        while match(types: .minus, .plus) {
            let `operator` = previous()
            let right = try factor()
            expr = Expr.Binary(left: expr, operator: `operator`, right: right)
        }

        return expr
    }

    private func factor() throws -> Expr {
        var expr = try unary()

        while match(types: .slash, .star) {
            let `operator` = previous()
            let right = try unary()
            expr = Expr.Binary(left: expr, operator: `operator`, right: right)
        }

        return expr
    }

    private func unary() throws -> Expr {
        if match(types: .bang, .minus) {
            let `operator` = previous()
            let right = try unary()
            return Expr.Unary(operator: `operator`, right: right)
        }

        return try call()
    }

    private func finishCall(_ callee: Expr) throws -> Expr {
        var arguments: [Expr] = []
        if !check(type: .rightParen) {
            repeat {
                if arguments.count >= 255 {
                    _ = error(at: peek(), message: "Can't have more than 255 arguments.")
                }
                arguments.append(try expression())
            } while match(types: .comma)
        }
        
        let paren = try consume(type: .rightParen, message: "Expect ')' after arguments.")
        return Expr.Call(callee: callee, paren: paren, arguments: arguments)
    }

    private func call() throws -> Expr {
        var expr = try `subscript`() // parses the callee

        while true {
            if match(types: .leftParen) {
                expr = try finishCall(expr)
            } else if match(types: .dot) {
                let name = try consume(type: .identifier, message: "Expect property name after '.'.")
                expr = Expr.Get(object: expr, name: name)
            }
            else {
                break
            }
        }
        return expr
    }
    
    private func `subscript`() throws -> Expr {
        var expr = try primary()
        while true {
            if (match(types: .leftBracket)) {
                expr = try finishSubscript(expr)
            } else {
                break
            }
        }
        return expr
    }
    
    private func finishSubscript(_ expr: Expr) throws -> Expr {
        let index = try or()
        let paren = try consume(type: .rightBracket, message: "Expect ']' after arguments.")
        return Expr.Subscript(name: expr, index: index, value: nil, paren: paren)
    }

    private func primary() throws -> Expr {
        if match(types: .false) { return Expr.Literal(value: false) }
        if match(types: .true) { return Expr.Literal(value: true) }
        if match(types: .nil) { return Expr.Literal(value: nil) }

        if match(types: .number, .string) {
            return Expr.Literal(value: previous().literal)
        }

        if match(types: .super) {
            let keyword = previous()
            _ = try consume(type: .dot, message: "Expect '.' after 'super'.")
            let method = try consume(type: .identifier, message: "Expect superclass method name.")
            return Expr.Super(keyword: keyword, method: method)
        }

        if match(types: .identifier) {
            return Expr.Variable(name: previous())
        }

        if match(types: .leftParen) {
            let expr = try expression()
            _ = try consume(type: .rightParen, message: "Expect ')' after expression.")
            return Expr.Grouping(expression: expr)
        }
        
        if match(types: .leftBrace) {
            return try list()
        }

        throw error(at: peek(), message: "Expect expression.")
    }
    
    private func list() throws -> Expr {
        var values: [Expr] = []
        if match(types: .rightBrace) {
            return Expr.List(values: values)
        } else {
            repeat {
                if values.count >= 255 {
                    throw error(at: peek(), message: "Expect expression.")
                }
                let value = try or()
                values.append(value)
            } while match(types: .comma)
        }
        _ = try consume(type: .rightBrace, message: "Expect ']' at end of list.")
        return Expr.List(values: values)
    }
}
