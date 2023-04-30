//
//  CPlusPrinter.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 28.04.2023.
//

import Foundation


class CPlusPrinter {
    private var indentationLevel = 0
    private var currentSuperClass: Token?
    
    private var indent: String {
        String(repeating: "    ", count: indentationLevel)
    }
    
    func printCode(_ statements: [Stmt]) throws {
        for statement in statements {
            print(try printNode(statement))
        }
    }
    
    private func printNode(_ expr: Expr) throws -> String {
        try expr.accept(visitor: self)
    }
    
    private func printNode(_ stmt: Stmt) throws -> String {
        try stmt.accept(visitor: self)
    }
    
    private func handleTypeRepresentation(_ type: CType) -> String {
        /// in C++ array initialization works like this:
        /// `int arr[5] = {1, 2, 3, 4, 5};`
        /// But in out language its:
        /// `int[] arr = {1, 2, 3, 4, 5};`
        /// so we fix it by removing the brackets
        switch type {
        case .intArray, .stringArray, .doubleArray, .floatArray, .charArray, .boolArray:
            return String(type.rawValue.dropLast(2))
        default:
            return type.rawValue
        }
    }
}

extension CPlusPrinter: ExprVisitor {
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> String {
        "\(expr.name.lexeme) = \(try printNode(expr.value))"
    }
    
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> String {
        "\(try printNode(expr.left)) \(expr.operator.lexeme) \(try printNode(expr.right))"
    }
    
    func visitCallExpr(_ expr: Expr.Call) throws -> String {
        let arguments = try expr.arguments.map { try printNode($0) }.joined(separator: ", ")
        return "\(try printNode(expr.callee))(\(arguments))"
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> String {
        "\(try printNode(expr.object)).\(expr.name.lexeme)"
    }
    
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> String {
        "(\(try printNode(expr.expression)))"
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
        "(\(try printNode(expr.left)) \(expr.operator.lexeme) \(try printNode(expr.right)))"
    }
    
    func visitSetExpr(_ expr: Expr.Set) throws -> String {
        "\(try printNode(expr.object)).\(expr.name.lexeme) = \(try printNode(expr.value))"
    }
    
    func visitSuperExpr(_ expr: Expr.Super) throws -> String {
        if let currentSuperClass = currentSuperClass {
            return "\(currentSuperClass.lexeme)::\(expr.method.lexeme)"
        }
        return "\(expr.method.lexeme)()"
    }
    
    func visitThisExpr(_ expr: Expr.This) throws -> String {
        ""
    }
    
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> String {
        "(\(expr.operator.lexeme)\(try printNode(expr.right)))"
    }
    
    func visitVariableExpr(_ expr: Expr.Variable) throws -> String {
        expr.name.lexeme
    }
    
    func visitListExpr(_ expr: Expr.List) throws -> String {
        let elements = try expr.values.map { try printNode($0) }.joined(separator: ", ")
        return "{\(elements)}"
    }
    
    func visitSubscriptExpr(_ expr: Expr.Subscript) throws -> String {
        var subscriptStr = "\(try printNode(expr.name))[\(try printNode(expr.index))]"
        if let value = expr.value {
            subscriptStr += " = \(try printNode(value))"
        }
        return subscriptStr
    }
    
}

extension CPlusPrinter: StmtVisitor {
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> String {
        var blockStr = ""
        for (index, statement) in stmt.statements.enumerated() {
            blockStr += "\(indent)\(try printNode(statement))"
            if index < stmt.statements.count - 1 {
                blockStr += "\n"
            }
        }
        return blockStr
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> String {
        var classStr = "\nclass \(stmt.name.lexeme)"
        if let superclass = stmt.superclass {
            classStr += " : public \(superclass.name.lexeme)"
            currentSuperClass = superclass.name
        }
        classStr += " {\n"
        /// We dont handle protection level in our language
        /// so when we converting to c++ we just make everything public
        classStr += "public:\n"
        indentationLevel += 1
        for method in stmt.methods {
            classStr += "\(indent)\(try printNode(method))\n"
        }
        indentationLevel -= 1
        classStr += "\(indent)};\n"
        currentSuperClass = nil
        return classStr
    }
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> String {
        "\(try printNode(stmt.expression));"
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> String {
        var functionStr = "\(handleTypeRepresentation(stmt.type)) \(stmt.name.lexeme)("
        for (index, param) in stmt.params.enumerated() {
            functionStr += param.name.lexeme
            if index < stmt.params.count - 1 {
                functionStr += ", "
            }
        }
        functionStr += ") {\n"
        indentationLevel += 1
        for statement in stmt.body {
            functionStr += "\(indent)\(try printNode(statement))\n"
        }
        indentationLevel -= 1
        functionStr += "\(indent)}\n"
        return functionStr
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> String {
        var ifStr = "if (\(try printNode(stmt.condition))) {\n"
        indentationLevel += 1
        ifStr += "\(try printNode(stmt.thenBranch))\n"
        indentationLevel -= 1
        ifStr += "\(indent)}"
        if let elseBranch = stmt.elseBranch {
            ifStr += " else {\n"
            indentationLevel += 1
            ifStr += "\(try printNode(elseBranch))\n"
            indentationLevel -= 1
            ifStr += "\(indent)}"
        }
        return ifStr
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> String {
        "std::cout << (\(try printNode(stmt.expression)));"
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> String {
        var returnStr = "return"
        if let value = stmt.value {
            returnStr += " \(try printNode(value))"
        }
        returnStr += ";"
        return returnStr
    }
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> String {
        var varStr = "\(handleTypeRepresentation(stmt.type)) \(stmt.name.lexeme)"
        if let initializer = stmt.initializer {
            if let listExpr = initializer as? Expr.List {
                varStr += "[\(listExpr.values.count)] = \(try printNode(listExpr))"
            } else {
                varStr += " = \(try printNode(initializer))"
            }
        }
        varStr += ";"
        return varStr
    }
    
    func visitWhileStmt(_ stmt: Stmt.While) throws -> String {
        var whileStr = "while (\(try printNode(stmt.condition))) {\n"
        indentationLevel += 1
        whileStr += "\(try printNode(stmt.body))\n"
        indentationLevel -= 1
        whileStr += "\(indent)}"
        return whileStr
    }
}
