//
//  AstPrinter.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 08.04.2023.
//

import Foundation

class AstPrinter {
    
    func printNode(_ expr: Expr) throws -> String {
        return try expr.accept(visitor: self)
    }
    
    func printNode(_ stmt: Stmt) throws -> String {
        return try stmt.accept(visitor: self)
    }
    
    private func parenthesize(_ name: String, _ exprs: Expr...) throws -> String {
        var builder = ""
        for expr in exprs {
            builder.append(try expr.accept(visitor: self))
            builder.append(" ")
        }
        builder.append(name)
        return builder
    }

    private func parenthesize(_ name: String, _ parts: Any...) throws -> String {
        var builder = ""
        try transform(&builder, parts)
        builder.append(name)
        return builder
    }
    
    private func transform(_ builder: inout String, _ parts: [Any]) throws {
        var buffer: [String] = []
        for part in parts {
            switch part {
            case let expr as Expr:
                builder.append(try expr.accept(visitor: self))
                builder.append(" ")
            case let stmt as Stmt:
                builder.append(try stmt.accept(visitor: self))
                builder.append(" ")
            case let token as Token:
                builder.append(token.lexeme)
                builder.append(" ")
            case let list as [Any]:
                try transform(&builder, list)
            default:
                buffer.append(String(describing: part))
            }
        }
        for element in buffer {
            builder.append(element)
            builder.append(" ")
        }
    }
}

extension AstPrinter: StmtVisitor {
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> String {
        var builder = ""
        builder.append("(")
        for statement in stmt.statements {
            builder.append(try statement.accept(visitor: self))
        }
        builder.append(")")
        return builder
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> String {
        var builder = ""
        builder.append("(\(stmt.name.lexeme) _class_")
        if let superclass = stmt.superclass {
            builder.append(" < \(try printNode(superclass))")
        }
        for method in stmt.methods {
            builder.append(" \(try printNode(method))")
        }
        builder.append(")")
        return builder
    }
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> String {
        return try parenthesize("", stmt.expression)
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> String {
        var builder = ""
        builder.append("\(stmt.name.lexeme) (")
        
        for (index, param) in stmt.params.enumerated() {
            if index != 0 { builder.append(" ") }
            builder.append("\(param.name.lexeme) \(param.type)")
        }
        builder.append(") \(stmt.type) (")
        for body in stmt.body {
            builder.append(try body.accept(visitor: self))
        }
        builder.append(")")
        return builder
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> String {
        if stmt.elseBranch == nil {
            return try parenthesize("_if_", stmt.condition, stmt.thenBranch)
        }
        return try parenthesize("_if-else_", stmt.condition, stmt.thenBranch, stmt.elseBranch as Any)
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> String {
        return try parenthesize("print", stmt.expression)
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> String {
        if stmt.value == nil { return "(return)" }
        return try parenthesize("return", stmt.value as Any)
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> String {
        if stmt.initializer == nil {
            return try parenthesize(stmt.type.rawValue, stmt.name)
        }
        return try parenthesize(stmt.type.rawValue, stmt.name, "=", stmt.initializer as Any)
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> String {
        return try parenthesize("while", stmt.condition, stmt.body)
    }
}

extension AstPrinter: ExprVisitor {
    
    func visitListExpr(_ expr: Expr.List) throws -> String {
        var builder = "("
        for element in expr.values {
            builder.append(" ")
            builder.append(try printNode(element))
        }
        builder.append(" _(\(expr.values.count))array_ ")
        builder.append(")")
        return builder
    }
    
    func visitSubscriptExpr(_ expr: Expr.Subscript) throws -> String {
        if let value = expr.value {
            return try parenthesize("_set_", expr.name, expr.index, value)
        } else {
            return try parenthesize("_get_", expr.name, expr.index)
        }
    }
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> String {
        return try parenthesize("=", expr.name.lexeme, expr.value)
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> String {
        return try parenthesize(expr.operator.lexeme, expr.left, expr.right)
    }
    
    func visitCallExpr(_ expr: Expr.Call) throws -> String {
        return try parenthesize("_call_", expr.callee, expr.arguments)
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> String {
        return try parenthesize("_method_", expr.object, expr.name.lexeme)
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> String {
        return try parenthesize("_group_", expr.expression)
    }
    
    func visitLiteralExpr(_ expr: Expr.Literal) -> String {
        if expr.value == nil { return "null" }
        return String(describing: expr.value!)
    }
    
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> String {
        return try parenthesize(expr.operator.lexeme, expr.left, expr.right)
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> String {
        return try parenthesize("=", expr.object, expr.name.lexeme, expr.value)
    }
    
    func visitSuperExpr(_ expr: Expr.Super) throws -> String {
        return try parenthesize("_base_", expr.method)
    }
    
    func visitThisExpr(_ expr: Expr.This) -> String {
        return "_base_"
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> String {
        return try parenthesize(expr.operator.lexeme, expr.right)
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) -> String {
        return expr.name.lexeme
    }
}
