//
//  Resolver.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

class Resolver {
    
    enum FunctionType {
        case none
        case function
        case initializer
        case method
    }
    
    enum ClassType {
        case none
        case `class`
        case subclass
    }
    
    private let interpreter: Interpreter
    private var scopes: [[String: Bool]] = []
    private var currentFunction: FunctionType = .none
    private var currentClass: ClassType = .none
    private var identifiers: [[Token: Int]] = []
    
    init(interpreter: Interpreter) {
        self.interpreter = interpreter
        identifiers.append([:])
        scopes.append([:])
    }
    
    private func beginScope() {
        identifiers.append([:])
        scopes.append([:])
    }
    
    private func endScope() {
        identifiers.removeLast()
        scopes.removeLast()
    }
    
    func declare(_ name: Token) {
        guard !scopes.isEmpty && !identifiers.isEmpty else { return }
        if var currentScope = scopes.last, var currentBlock = identifiers.last {
            if currentScope[name.lexeme] != nil {
                Language.error(token: name, message: "Already a variable with this name in this scope.")
            }
            currentBlock[name] = 0
            currentScope[name.lexeme] = false
            
            identifiers[identifiers.count - 1] = currentBlock
            scopes[scopes.count - 1] = currentScope
        }
    }
    
    private func define(_ name: Token) {
        guard !scopes.isEmpty else { return }
        scopes[scopes.count - 1][name.lexeme] = true
    }
    
    func resolve(_ statements: [Stmt]) throws {
        for statement in statements {
            try resolve(statement)
        }
    }
    
    private func resolveLocal(expr: Expr, name: Token) {
        for (i, scope) in scopes.enumerated().reversed() {
            if scope.keys.contains(name.lexeme) {
                identifiers[i].removeValue(forKey: name)
                interpreter.resolve(expr: expr, depth: scopes.count - 1 - i)
                return
            }
        }
    }
    
    private func resolve(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    private func resolve(_ expr: Expr) throws {
        try expr.accept(visitor: self)
    }
    
    private func resolveFunction(_ function: Stmt.Function, type: FunctionType) throws {
        let enclosingFunction = currentFunction
        currentFunction = type
        
        beginScope()
        for param in function.params {
            declare(param.name)
            define(param.name)
        }
        try resolve(function.body)
        endScope()
        
        currentFunction = enclosingFunction
    }
    
}

extension Resolver: StmtVisitor {
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> () {
        beginScope()
        try resolve(stmt.statements)
        endScope()
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> () {
        declare(stmt.name)
        define(stmt.name)
        
        let enclosingClass = currentClass
        currentClass = .class
        
        if let superclass = stmt.superclass {
            if stmt.name.lexeme == superclass.name.lexeme {
                Language.error(token: superclass.name, message: "A class can't inherit from itself.")
            }
            currentClass = .subclass
            try resolve(superclass)
            
            beginScope()
            scopes[scopes.count - 1]["base"] = true
        }
        
        beginScope()
        
        for method in stmt.methods {
            let declaration: FunctionType = method.name.lexeme == "init" ? .initializer : .method
            try resolveFunction(method, type: declaration)
        }
        
        endScope()
        
        if stmt.superclass != nil {
            endScope()
        }
        
        currentClass = enclosingClass
    }
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> () {
        try resolve(stmt.expression)
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> () {
        declare(stmt.name)
        define(stmt.name)
        try resolveFunction(stmt, type: .function)
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> () {
        try resolve(stmt.condition)
        try resolve(stmt.thenBranch)
        if let elseBranch = stmt.elseBranch {
            try resolve(elseBranch)
        }
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> () {
        try resolve(stmt.expression)
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> () {
        if currentFunction == .none {
            Language.error(token: stmt.keyword, message: "Can't return from top-level code.")
        }
        
        if let value = stmt.value {
            if currentFunction == .initializer {
                Language.error(token: stmt.keyword, message: "Can't return a value from an initializer.")
            }
            try resolve(value)
        }
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> () {
        declare(stmt.name)
        if let initializer = stmt.initializer {
            try resolve(initializer)
        }
        define(stmt.name)
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> () {
        try resolve(stmt.condition)
        try resolve(stmt.body)
    }
}

extension Resolver: ExprVisitor {
    
    func visitListExpr(_ expr: Expr.List) throws -> () {
        for value in expr.values {
            try resolve(value)
        }
    }
    
    func visitSubscriptExpr(_ expr: Expr.Subscript) throws -> () {
        try resolve(expr.name)
        try resolve(expr.index)
        if let value = expr.value {
            try resolve(value)
        }
    }
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> () {
        try resolve(expr.value)
        resolveLocal(expr: expr, name: expr.name)
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> () {
        try resolve(expr.left)
        try resolve(expr.right)
    }
    
    func visitCallExpr(_ expr: Expr.Call) throws -> () {
        try resolve(expr.callee)
        
        for argument in expr.arguments {
            try resolve(argument)
        }
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> () {
        try resolve(expr.object)
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> () {
        try resolve(expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> () {
        return
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> () {
        try resolve(expr.left)
        try resolve(expr.right)
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> () {
        try resolve(expr.value)
        try resolve(expr.object)
    }
    
    func visitSuperExpr(_ expr: Expr.Super) throws -> () {
        if currentClass == .none {
            Language.error(token: expr.keyword, message: "Can't use 'super' outside of a class.")
        } else if currentClass != .subclass {
            Language.error(token: expr.keyword, message: "Can't use 'super' in a class with no superclass.")
        }
        resolveLocal(expr: expr, name: expr.keyword)
    }
    
    func visitThisExpr(_ expr: Expr.This) throws -> () {
        if currentClass == .none {
            Language.error(token: expr.keyword, message: "Can't use 'this' outside of a class.")
            return
        }
        resolveLocal(expr: expr, name: expr.keyword)
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> () {
        try resolve(expr.right)
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> () {
        if let isInitialized = scopes.last?[expr.name.lexeme], !isInitialized {
            Language.error(token: expr.name, message: "Can't read local variable in its own initializer.")
            return
        }
        resolveLocal(expr: expr, name: expr.name)
    }
}
