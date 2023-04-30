//
//  Expr.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

protocol ExprVisitor {
    associatedtype ReturnTypeExpr
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> ReturnTypeExpr
    func visitBinaryExpr(_ expr: Expr.Binary) throws -> ReturnTypeExpr
    func visitCallExpr(_ expr: Expr.Call) throws -> ReturnTypeExpr
    func visitGetExpr(_ expr: Expr.Get) throws -> ReturnTypeExpr
    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> ReturnTypeExpr
    func visitLiteralExpr(_ expr: Expr.Literal) throws -> ReturnTypeExpr
    func visitLogicalExpr(_ expr: Expr.Logical) throws -> ReturnTypeExpr
    func visitSetExpr(_ expr: Expr.Set) throws -> ReturnTypeExpr
    func visitSuperExpr(_ expr: Expr.Super) throws -> ReturnTypeExpr
    func visitThisExpr(_ expr: Expr.This) throws -> ReturnTypeExpr
    func visitUnaryExpr(_ expr: Expr.Unary) throws -> ReturnTypeExpr
    func visitVariableExpr(_ expr: Expr.Variable) throws -> ReturnTypeExpr
    func visitListExpr(_ expr: Expr.List) throws -> ReturnTypeExpr
    func visitSubscriptExpr(_ expr: Expr.Subscript) throws -> ReturnTypeExpr
}

class Expr {
    func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
        fatalError("Must be overridden by subclass")
    }
}

extension Expr: Hashable {
    static func == (lhs: Expr, rhs: Expr) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

// MARK: - Expression Nodes
extension Expr {
    class List: Expr {
        let values: [Expr]
        
        init(values: [Expr]) {
            self.values = values
        }

        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            try visitor.visitListExpr(self)
        }
    }

    class Subscript: Expr {
        let name: Expr
        let index: Expr
        let value: Expr?
        let paren: Token
        let type: AssignType?

        init(name: Expr, index: Expr, value: Expr?, paren: Token, type: AssignType?) {
            self.name = name
            self.index = index
            self.value = value
            self.paren = paren
            self.type = type
        }

        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            try visitor.visitSubscriptExpr(self)
        }
    }
    
    class Assign: Expr {
        let name: Token
        let value: Expr
        let type: AssignType
        
        init(name: Token, value: Expr, type: AssignType) {
            self.name = name
            self.value = value
            self.type = type
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitAssignExpr(self)
        }
    }
    
    class Binary: Expr {
        let left: Expr
        let `operator`: Token
        let right: Expr
        
        init(left: Expr, `operator`: Token, right: Expr) {
            self.left = left
            self.operator = `operator`
            self.right = right
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitBinaryExpr(self)
        }
    }
    
    class Call: Expr {
        let callee: Expr
        let paren: Token
        let arguments: [Expr]
        
        init(callee: Expr, paren: Token, arguments: [Expr]) {
            self.callee = callee
            self.paren = paren
            self.arguments = arguments
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitCallExpr(self)
        }
    }
    
    class Get: Expr {
        let object: Expr
        let name: Token
        
        init(object: Expr, name: Token) {
            self.object = object
            self.name = name
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitGetExpr(self)
        }
    }
    
    class Grouping: Expr {
        let expression: Expr
        
        init(expression: Expr) {
            self.expression = expression
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitGroupingExpr(self)
        }
    }
    
    class Literal: Expr {
        let value: Any?
        
        init(value: Any?) {
            self.value = value
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitLiteralExpr(self)
        }
    }
    
    class Logical: Expr {
        let left: Expr
        let `operator`: Token
        let right: Expr
        
        init(left: Expr, `operator`: Token, right: Expr) {
            self.left = left
            self.operator = `operator`
            self.right = right
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitLogicalExpr(self)
        }
    }
    
    class Set: Expr {
        let object: Expr
        let name: Token
        let value: Expr
        let type: AssignType
        
        init(object: Expr, name: Token, value: Expr, type: AssignType) {
            self.object = object
            self.name = name
            self.value = value
            self.type = type
        }
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitSetExpr(self)
        }
    }
    
    class Super: Expr {
        let keyword: Token
        let method: Token
        
        init(keyword: Token, method: Token) {
            self.keyword = keyword
            self.method = method
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitSuperExpr(self)
        }
    }
    
    class This: Expr {
        let keyword: Token
        
        init(keyword: Token) {
            self.keyword = keyword
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitThisExpr(self)
        }
    }
    
    class Unary: Expr {
        let `operator`: Token
        let right: Expr
        
        init(`operator`: Token, right: Expr) {
            self.operator = `operator`
            self.right = right
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitUnaryExpr(self)
        }
    }
    
    class Variable: Expr {
        let name: Token
        
        init(name: Token) {
            self.name = name
        }
        
        override func accept<T: ExprVisitor>(visitor: T) throws -> T.ReturnTypeExpr {
            return try visitor.visitVariableExpr(self)
        }
    }
}
