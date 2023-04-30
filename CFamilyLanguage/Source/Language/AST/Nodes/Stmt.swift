//
//  Stmt.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

protocol StmtVisitor {
    associatedtype ReturnTypeStmt
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> ReturnTypeStmt
    func visitClassStmt(_ stmt: Stmt.Class) throws -> ReturnTypeStmt
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> ReturnTypeStmt
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> ReturnTypeStmt
    func visitIfStmt(_ stmt: Stmt.If) throws -> ReturnTypeStmt
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> ReturnTypeStmt
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> ReturnTypeStmt
    func visitVarStmt(_ stmt: Stmt.Var) throws -> ReturnTypeStmt
    func visitWhileStmt(_ stmt: Stmt.While) throws -> ReturnTypeStmt
}

class Stmt {
    func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
        fatalError("Must be implemented by subclasses")
    }
}

// MARK: Statement Nodes
extension Stmt {
    class Block: Stmt {
        let statements: [Stmt]
        
        init(statements: [Stmt]) {
            self.statements = statements
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitBlockStmt(self)
        }
    }
    
    class Class: Stmt {
        let name: Token
        let superclass: Expr.Variable?
        let methods: [Stmt.Function]
        
        init(name: Token, superclass: Expr.Variable?, methods: [Stmt.Function]) {
            self.name = name
            self.superclass = superclass
            self.methods = methods
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitClassStmt(self)
        }
    }
    
    class Expression: Stmt {
        let expression: Expr
        
        init(expression: Expr) {
            self.expression = expression
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitExpressionStmt(self)
        }
    }
    
    class Function: Stmt {
        
        let name: Token
        let type: CType
        let params: [Var]
        let body: [Stmt]
        
        init(name: Token, type: CType, params: [Var], body: [Stmt]) {
            self.name = name
            self.params = params
            self.body = body
            self.type = type
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitFunctionStmt(self)
        }
    }
    
    class If: Stmt {
        let condition: Expr
        let thenBranch: Stmt
        let elseBranch: Stmt?
        
        init(condition: Expr, thenBranch: Stmt, elseBranch: Stmt?) {
            self.condition = condition
            self.thenBranch = thenBranch
            self.elseBranch = elseBranch
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitIfStmt(self)
        }
    }
    
    class Print: Stmt {
        let expression: Expr
        
        init(expression: Expr) {
            self.expression = expression
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitPrintStmt(self)
        }
    }
    
    class Return: Stmt {
        let keyword: Token
        let value: Expr?
        
        init(keyword: Token, value: Expr?) {
            self.keyword = keyword
            self.value = value
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitReturnStmt(self)
        }
    }
    
    class Var: Stmt {
        let name: Token
        let initializer: Expr?
        let type: CType
        
        init(name: Token, type: CType, initializer: Expr?) {
            self.name = name
            self.type = type
            self.initializer = initializer
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitVarStmt(self)
        }
    }
    
    class While: Stmt {
        let condition: Expr
        let body: Stmt
        
        init(condition: Expr, body: Stmt) {
            self.condition = condition
            self.body = body
        }
        
        override func accept<T: StmtVisitor>(visitor: T) throws -> T.ReturnTypeStmt {
            return try visitor.visitWhileStmt(self)
        }
    }
}
