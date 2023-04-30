//
//  AstPrinter.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 08.04.2023.
//

import Foundation

class AstPrinter {
    
    func printNodes(_ statements: [Stmt]) throws {
        for statement in statements {
            print(try printNode(statement))
        }
    }
    
    private func printNode(_ expr: Expr) throws -> String {
        return try expr.accept(visitor: self)
    }
    
    private func printNode(_ stmt: Stmt) throws -> String {
        return try stmt.accept(visitor: self)
    }
}


// MARK: - Expressions
extension AstPrinter: ExprVisitor {
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> String {
        try expr.name.lexeme + " " + expr.type.rawValue + " " + printNode(expr.value)
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> String {
        try printNode(expr.left) + " " + expr.operator.lexeme + " " + printNode(expr.right)
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
        try printNode(expr.right) + " " + expr.operator.lexeme + " " + printNode(expr.left)
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> String {
        try printNode(expr.object) + " " + expr.name.lexeme + " " + expr.type.rawValue + " " + printNode(expr.value)
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
        var builder = "( ARRAY LENGTH(\(expr.values.count))"
        for element in expr.values {
            builder += try " " + printNode(element)
        }
        builder += " )"
        return builder
    }
    
    func visitSubscriptExpr(_ expr: Expr.Subscript) throws -> String {
        let builder = try printNode(expr.name) + " INDEX(" + printNode(expr.index) + ")"
        if let value = expr.value {
            return try builder + " " + (expr.type?.rawValue ?? "=") + " " + printNode(value)
        }
        return "GET " + builder
    }
}

// MARK: - Statements
extension AstPrinter: StmtVisitor {
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> String {
        var builder = "( "
        for statement in stmt.statements {
            builder += try printNode(statement) + " "
        }
        builder += ")"
        return builder
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> String {
        var builder = "( CLASS \(stmt.name.lexeme)"
        if let superclass = stmt.superclass {
            builder += try " < PARENTCLASS " + printNode(superclass)
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
        var builder = "\(stmt.type.rawValue) \(stmt.name.lexeme) ("
        
        for (index, param) in stmt.params.enumerated() {
            if index != 0 { builder += " " }
            builder += "\(param.type) \(param.name.lexeme)"
        }
        builder += ") ("
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
        try "(PRINT " + printNode(stmt.expression) + ")"
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> String {
        if let value = stmt.value {
            return try "(RETURN " + printNode(value) + ")"
        }
        return "RETURN"
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> String {
        if let initializer = stmt.initializer {
            return try stmt.type.rawValue + " " + stmt.name.lexeme + " = " + printNode(initializer)
        }
        return stmt.type.rawValue + " " + stmt.name.lexeme
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> String {
        try "WHILE " + printNode(stmt.condition) + " DO " + printNode(stmt.body) + " END"
    }
    
}
