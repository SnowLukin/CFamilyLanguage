//
//  RPNPrinter.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 30.04.2023.
//

import Foundation

class RPNPrinter {
    
    func printNodes(_ statements: [Stmt]) throws {
        for statement in statements {
            print(try printNode(statement))
        }
    }
    
    private func printNode(_ stmt: Stmt) throws -> String {
        try stmt.accept(visitor: self)
    }
    
    private func printNode(_ expr: Expr) throws -> String {
        try expr.accept(visitor: self)
    }
}

extension RPNPrinter: ExprVisitor {
    func visitAssignExpr(_ expr: Expr.Assign) throws -> String {
        try expr.name.lexeme + " " + printNode(expr.value) + " " + expr.type.rawValue
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> String {
        try printNode(expr.left) + " " + printNode(expr.right) + " " + expr.operator.lexeme
    }
    
    func visitCallExpr(_ expr: Expr.Call) throws -> String {
        try printNode(expr.callee) + " " + expr.arguments.map { try printNode($0) }.joined(separator: " ") + "CALL"
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> String {
        try printNode(expr.object) + " " + expr.name.lexeme
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> String {
        try "(" + printNode(expr.expression) + ")"
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> String {
        if let value = expr.value {
            return String(describing: value)
        }
        return "null"
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> String {
        try printNode(expr.right) + " " + printNode(expr.left) + " " + expr.operator.lexeme
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> String {
        try printNode(expr.object) + " " + expr.name.lexeme + " " + printNode(expr.value) + " " + expr.type.rawValue
    }
    
    func visitSuperExpr(_ expr: Expr.Super) throws -> String {
        "BASE.\(expr.method.lexeme)"
    }
    
    func visitThisExpr(_ expr: Expr.This) throws -> String {
        "BASE"
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> String {
        try expr.operator.lexeme + printNode(expr.right)
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> String {
        expr.name.lexeme
    }
    
    func visitListExpr(_ expr: Expr.List) throws -> String {
        var builder = "("
        for element in expr.values {
            builder += try " " + printNode(element)
        }
        builder += " LENGTH(\(expr.values.count)) ARRAY )"
        return builder
    }
    
    func visitSubscriptExpr(_ expr: Expr.Subscript) throws -> String {
        let builder = try printNode(expr.name) + " INDEX(" + printNode(expr.index) + ") "
        if let value = expr.value {
            return try builder + printNode(value) + " " + (expr.type?.rawValue ?? "=")
        }
        return builder + "GET"
    }
}

extension RPNPrinter: StmtVisitor {
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> String {
        var builder = "( "
        for statement in stmt.statements {
            builder += try printNode(statement) + " "
        }
        builder += ")"
        return builder
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> String {
        var builder = "( \(stmt.name.lexeme) CLASS"
        if let superclass = stmt.superclass {
            builder += try " < " + printNode(superclass) + " PARENTCLASS"
        }
        builder += " ("
        for method in stmt.methods {
            builder += try printNode(method)
        }
        builder += ") )"
        return builder
    }
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> String {
        try printNode(stmt.expression)
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> String {
        var builder = "\(stmt.name.lexeme) ("
        
        for (index, param) in stmt.params.enumerated() {
            if index != 0 { builder += " " }
            builder += "\(param.name.lexeme) \(param.type)"
        }
        builder += ") \(stmt.type.rawValue) ("
        for body in stmt.body {
            builder += try printNode(body)
        }
        builder += ")"
        return builder
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> String {
        var result = try "IF " + printNode(stmt.condition) + " THEN " + printNode(stmt.thenBranch)
        if let elseBranch = stmt.elseBranch {
            result += try " ELSE " + printNode(elseBranch)
        }
        result += " END"
        return result
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> String {
        try "(" + printNode(stmt.expression) + " PRINT)"
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> String {
        if let value = stmt.value {
            return try "(" + printNode(value) + " RETURN)"
        }
        return "RETURN"
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> String {
        if let initializer = stmt.initializer {
            return try stmt.name.lexeme + " " + printNode(initializer) + " = " + stmt.type.rawValue
        }
        return stmt.name.lexeme + " " + stmt.type.rawValue
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> String {
        try "WHILE " + printNode(stmt.condition) + " DO " + printNode(stmt.body) + " END"
    }
    
}
