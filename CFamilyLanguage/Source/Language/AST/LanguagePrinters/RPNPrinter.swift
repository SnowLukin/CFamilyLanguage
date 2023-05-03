//
//  RPNPrinter.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 30.04.2023.
//

import Foundation

class RPNPrinter {
    
    func getNodes(_ statements: [Stmt]) throws -> String {
        try statements.map { try getNode($0) }.joined(separator: "\n")
    }
    
    private func getNode(_ stmt: Stmt) throws -> String {
        try stmt.accept(visitor: self)
    }
    
    private func getNode(_ expr: Expr) throws -> String {
        try expr.accept(visitor: self)
    }
}

extension RPNPrinter: ExprVisitor {
    func visitAssignExpr(_ expr: Expr.Assign) throws -> String {
        try expr.name.lexeme + " " + getNode(expr.value) + " " + expr.type.rawValue
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> String {
        try getNode(expr.left) + " " + getNode(expr.right) + " " + expr.operator.lexeme
    }
    
    func visitCallExpr(_ expr: Expr.Call) throws -> String {
        var builder = try getNode(expr.callee) + " "
        for argument in expr.arguments {
            builder += try getNode(argument) + " "
        }
        return builder + "CALL"
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> String {
        try getNode(expr.object) + " " + expr.name.lexeme
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> String {
        try "(" + getNode(expr.expression) + ")"
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> String {
        if let value = expr.value {
            if let value = value as? String {
                return "\"\(value)\""
            }
            return String(describing: value)
        }
        return "null"
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> String {
        try getNode(expr.right) + " " + getNode(expr.left) + " " + expr.operator.lexeme
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> String {
        try getNode(expr.object) + " " + expr.name.lexeme + " " + getNode(expr.value) + " " + expr.type.rawValue
    }
    
    func visitSuperExpr(_ expr: Expr.Super) throws -> String {
        "BASE.\(expr.method.lexeme)"
    }
    
    func visitThisExpr(_ expr: Expr.This) throws -> String {
        "BASE"
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> String {
        try expr.operator.lexeme + getNode(expr.right)
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> String {
        expr.name.lexeme
    }
    
    func visitListExpr(_ expr: Expr.List) throws -> String {
        var builder = "("
        for element in expr.values {
            builder += try " " + getNode(element)
        }
        builder += " LENGTH(\(expr.values.count)) ARRAY )"
        return builder
    }
    
    func visitSubscriptExpr(_ expr: Expr.Subscript) throws -> String {
        let builder = try getNode(expr.name) + " INDEX(" + getNode(expr.index) + ") "
        if let value = expr.value {
            return try builder + getNode(value) + " " + (expr.type?.rawValue ?? "=")
        }
        return builder + "GET"
    }
}

extension RPNPrinter: StmtVisitor {
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> String {
        var builder = "BLOCK_START "
        for statement in stmt.statements {
            builder += try getNode(statement) + " "
        }
        builder += "BLOCK_END"
        return builder
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> String {
        var builder = "( \(stmt.name.lexeme) CLASS"
        if let superclass = stmt.superclass {
            builder += try " < " + getNode(superclass) + " PARENTCLASS"
        }
        builder += " ("
        for method in stmt.methods {
            builder += try getNode(method)
        }
        builder += ") )"
        return builder
    }
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> String {
        try getNode(stmt.expression)
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> String {
        var builder = "\(stmt.name.lexeme)"
        
        for param in stmt.params {
            builder += " \(param.name.lexeme) \(param.type)"
        }
        builder += " FUNCTION(\(stmt.params.count)) \(stmt.type.rawValue) PROC_START "
        for component in stmt.body {
            builder += try getNode(component) + " "
        }
        builder += "PROC_END"
        return builder
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> String {
        var result = try getNode(stmt.condition) + " MARK_1 COND_JUMP " + getNode(stmt.thenBranch)
        if let elseBranch = stmt.elseBranch {
            result += try " MARK_2 UNCOND_JUMP MARK_1: " + getNode(elseBranch) + " MARK_2:"
        } else {
            result += " MARK_1:"
        }
        return result
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> String {
        try getNode(stmt.expression) + " PRINT"
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> String {
        if let value = stmt.value {
            return try getNode(value) + " RETURN"
        }
        return "RETURN"
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> String {
        if let initializer = stmt.initializer {
            return try stmt.name.lexeme + " " + getNode(initializer) + " = " + stmt.type.rawValue
        }
        return stmt.name.lexeme + " " + stmt.type.rawValue
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> String {
        try getNode(stmt.condition) + " LOOP_MARK COND_JUMP " + getNode(stmt.body) + " LOOP_MARK:"
    }
    
}
