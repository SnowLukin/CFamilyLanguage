//
//  Interpreter.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

struct Clock: LanguageCallable {
    func arity() -> Int {
        0
    }
    
    func call(interpreter: Interpreter, arguments: [Any]) throws -> Any {
        let currentTime = Date().timeIntervalSince1970 + Double(TimeZone.current.secondsFromGMT())
        let currentTimeInSeconds = currentTime / 1000.0
        return currentTimeInSeconds
    }
    
    func toString() -> String {
        return "<native fn>"
    }
}

class Interpreter {
    let globals = Environment()
    var isPrintable = true
    private var environment: Environment
    private var locals: [Expr: Int] = [:]
    
    init() {
        environment = globals
        globals.define("clock", type: .none, value: Clock())
    }
    
    func interpret(statements: [Stmt], isPrintable: Bool = true) throws {
        self.isPrintable = isPrintable
        do {
            for statement in statements {
                try execute(statement)
            }
        } catch let error as RuntimeError {
            Language.runtimeError(error)
        }
    }
    
    private func evaluate(_ expr: Expr) throws -> Any? {
        try expr.accept(visitor: self)
    }
    
    private func execute(_ stmt: Stmt) throws {
        try stmt.accept(visitor: self)
    }
    
    func resolve(expr: Expr, depth: Int) {
        locals[expr] = depth
    }
    
    func executeBlock(statements: [Stmt], environment: Environment) throws {
        let previous = self.environment
        do {
            self.environment = environment
            for statement in statements {
                try execute(statement)
            }
        } catch {
            self.environment = previous
            throw error
        }
        self.environment = previous
    }
    
    private func handleAssigning(_ assignType: AssignType, token: Token, previousValue: Any?, newValue: Any?) throws -> Any? {
        guard let newValue = newValue, let previousValue = previousValue else { return nil }
        var resultValue: Any?
        switch assignType {
        case .assign:
            return newValue
        case .plusAssign:
            resultValue = Int.performOperation(+, previousValue, newValue)
            ?? Double.performOperation(+, previousValue, newValue)
            ?? String.performOperation(+, previousValue, newValue)
        case .minusAssign:
            resultValue = Int.performOperation(-, previousValue, newValue)
            ?? Double.performOperation(-, previousValue, newValue)
            if resultValue != nil { return resultValue }
            throw throwWrongType(token)
        case .slashAssign:
            resultValue = Int.performOperation(/, previousValue, newValue)
            ?? Double.performOperation(/, previousValue, newValue)
        case .starAssign:
            resultValue = Int.performOperation(*, previousValue, newValue)
            ?? Double.performOperation(*, previousValue, newValue)
        }
        if resultValue != nil { return resultValue }
        throw throwWrongType(token)
    }
    
    private func checkType(token: Token, type: CType, value: Any?) throws { // checking if the value matches the type
        if value == nil { return }
        switch type {
        case .int:
            if value as? Int == nil { throw throwWrongType(token) }
        case .float, .double:
            if value as? Double == nil { throw throwWrongType(token) }
        case .string:
            if value as? String == nil { throw throwWrongType(token) }
        case .char:
            if value as? String == nil || (value as? String)?.count ?? 0 > 1 {
                throw throwWrongType(token)
            }
        case .bool:
            if value as? Bool == nil { throw throwWrongType(token) }
        case .stringArray:
            guard let list = value as? LanguageList, list.values.filter({ $0 as? String == nil }).isEmpty else {
                throw throwWrongType(token)
            }
        case .intArray:
            guard let list = value as? LanguageList, list.values.filter({ $0 as? Int == nil }).isEmpty else {
                throw throwWrongType(token)
            }
        case .doubleArray, .floatArray:
            guard let list = value as? LanguageList, list.values.filter({ $0 as? Double == nil }).isEmpty else {
                throw throwWrongType(token)
            }
        case .charArray:
            guard let list = value as? LanguageList,
                    list.values.filter({ $0 as? String == nil && ($0 as? String)?.count ?? 0 > 1 }).isEmpty else {
                throw throwWrongType(token)
            }
        case .boolArray:
            guard let list = value as? LanguageList, list.values.filter({ $0 as? Bool == nil }).isEmpty else {
                throw throwWrongType(token)
            }
        case .void, .none:
            break
        }
    }
    
    private func throwWrongType(_ token: Token) -> RuntimeError {
        RuntimeError(token: token, message: "Value does not match variable's type")
    }

    private func lookUpVariable(name: Token, expr: Expr) throws -> Environment.Info {
        if let distance = locals[expr] {
            return environment.getAt(distance: distance, name: name.lexeme)
        }
        return try globals.get(name)
    }

    private func checkNumberOperand(operator: Token, operand: Any?) throws {
        if operand is Double { return }
        if operand is Int { return }
        throw RuntimeError(token: `operator`, message: "Operand must be a number.")
    }

    private func checkNumberOperands(operator: Token, left: Any?, right: Any?) throws {
        if left is Double && right is Double { return }
        if left is Int && right is Int { return }
        throw RuntimeError(token: `operator`, message: "Operands must be numbers.")
    }

    private func isTruthy(_ object: Any?) -> Bool {
        if object == nil { return false }
        if let boolValue = object as? Bool { return boolValue }
        return true
    }

    private func isEqual(_ a: Any?, _ b: Any?) -> Bool {
        if a == nil, b == nil { return true }
        if a == nil { return false }
        let a = a as AnyObject
        return a.isEqual(b as AnyObject)
    }

    private func stringify(_ object: Any?) -> String {
        guard let object = object else { return "nil" }
        if let doubleValue = object as? Double {
            var text = String(doubleValue)
            if text.hasSuffix(".0") {
                text = String(text.dropLast(2))
            }
            return text
        }
        if let intValue = object as? Int {
            return String(intValue)
        }
        
        if let stringValue = object as? String {
            return stringValue
        }
        
        if let boolValue = object as? Bool {
            return boolValue ? "true" : "false"
        }
        
        if let functionValue = object as? LanguageFunction {
            return functionValue.description
        }
        
        if let classValue = object as? LanguageClass {
            return classValue.description
        }
        
        if let listValue = object as? LanguageList {
            var result = "["
            for (index, value) in listValue.values.enumerated() {
                result.append(stringify(value))
                if index < listValue.values.count - 1 {
                    result.append(", ")
                }
            }
            result.append("]")
            return result
        }
        
        return "stringify: cannot recognize type"
    }
}

extension Interpreter: ExprVisitor {
    
    func visitListExpr(_ expr: Expr.List) throws -> Any? {
        let list = LanguageList()
        for value in expr.values {
            list.append(try evaluate(value))
        }
        return list
    }
    
    func visitSubscriptExpr(_ expr: Expr.Subscript) throws -> Any? {
        let name = try evaluate(expr.name)
        let index = try evaluate(expr.index)
        guard let list = name as? LanguageList else {
            throw RuntimeError(token: expr.paren, message: "Only lists can be subscripted.")
        }
        guard let castedIndex = index as? Int else {
            throw RuntimeError(token: expr.paren, message: "Index should be of type int.")
        }
        
        if let value = expr.value {
            let value = try evaluate(value)
            let previousValue = list.getEleAt(Int(castedIndex))
            if !value.canBeCastedToSameType(as: previousValue) || (value == nil && previousValue == nil) {
                throw RuntimeError(token: expr.paren, message: "Unexpected assignment value type.")
            }
            let newValue = try handleAssigning(expr.type!, token: expr.paren, previousValue: previousValue, newValue: value)
            if list.setAtIndex(Int(castedIndex), value: newValue) {
                return newValue
            }
            throw RuntimeError(token: expr.paren, message: "Index out of range.")
        } else {
            guard castedIndex >= 0 && Int(castedIndex) < list.length() else {
                throw RuntimeError(token: expr.paren, message: "Index out of range.")
            }
            return list.getEleAt(Int(castedIndex))
        }
    }
    
    func visitAssignExpr(_ expr: Expr.Assign) throws -> Any? {
        let value = try evaluate(expr.value)
        let variable = try lookUpVariable(name: expr.name, expr: expr)
        let type = variable.type
        let previousValue = variable.item
        let newValue = try handleAssigning(expr.type, token: expr.name, previousValue: previousValue, newValue: value)
        try checkType(token: expr.name, type: type, value: value)
        if let distance = locals[expr] {
            environment.assignAt(distance: distance, name: expr.name, type: type, value: newValue)
        } else {
            try globals.assign(expr.name, type: type, value: newValue)
        }
        return newValue
    }

    func visitBinaryExpr(_ expr: Expr.Binary) throws -> Any? {
        let left = try evaluate(expr.left)
        let right = try evaluate(expr.right)

        switch expr.operator.type {
        case .bangEqual:
            return !isEqual(left, right)
        case .equalEqual:
            return isEqual(left, right)
        case .greater:
            try checkNumberOperands(operator: expr.operator, left: left, right: right)
            if let left = left as? Double, let right = right as? Double { return left > right }
            if let left = left as? Int, let right = right as? Int { return left > right }
            throw RuntimeError(token: expr.operator, message: "Can only perform action with Int&Int or Double&Double.")
        case .greaterEqual:
            try checkNumberOperands(operator: expr.operator, left: left, right: right)
            if let left = left as? Double, let right = right as? Double { return left >= right }
            if let left = left as? Int, let right = right as? Int { return left >= right }
            throw RuntimeError(token: expr.operator, message: "Can only perform action with Int&Int or Double&Double.")
        case .less:
            try checkNumberOperands(operator: expr.operator, left: left, right: right)
            if let left = left as? Double, let right = right as? Double { return left < right }
            if let left = left as? Int, let right = right as? Int { return left < right }
            throw RuntimeError(token: expr.operator, message: "Can only perform action with Int&Int or Double&Double.")
        case .lessEqual:
            try checkNumberOperands(operator: expr.operator, left: left, right: right)
            if let left = left as? Double, let right = right as? Double { return left <= right }
            if let left = left as? Int, let right = right as? Int { return left <= right }
            throw RuntimeError(token: expr.operator, message: "Can only perform action with Int&Int or Double&Double.")
        case .minus:
            try checkNumberOperands(operator: expr.operator, left: left, right: right)
            if let left = left as? Double, let right = right as? Double { return left - right }
            if let left = left as? Int, let right = right as? Int { return left - right }
            throw RuntimeError(token: expr.operator, message: "Can only perform action with Int&Int or Double&Double.")
        case .plus:
            if let leftDouble = left as? Double, let rightDouble = right as? Double {
                return leftDouble + rightDouble
            }
            if let leftInt = left as? Int, let rightInt = right as? Int {
                return leftInt + rightInt
            }
            if let leftString = left as? String, let rightString = right as? String {
                return leftString + rightString
            }
            throw RuntimeError(token: expr.operator, message: "Operands must be two numbers or two strings.")
        case .slash:
            try checkNumberOperands(operator: expr.operator, left: left, right: right)
            if let left = left as? Double, let right = right as? Double { return left / right }
            if let left = left as? Int, let right = right as? Int { return left / right }
            throw RuntimeError(token: expr.operator, message: "Can only perform action with Int&Int or Double&Double.")
        case .star:
            try checkNumberOperands(operator: expr.operator, left: left, right: right)
            if let left = left as? Double, let right = right as? Double { return left * right }
            if let left = left as? Int, let right = right as? Int { return left * right }
            throw RuntimeError(token: expr.operator, message: "Can only perform action with Int&Int or Double&Double.")
        default:
            return nil
        }
    }

    func visitCallExpr(_ expr: Expr.Call) throws -> Any? {
        let callee = try evaluate(expr.callee)  // name of the function
        var arguments: [Any] = []
        for argument in expr.arguments {
            arguments.append(try evaluate(argument) ?? "nil")
        }
        guard let function = callee as? LanguageCallable else {
            throw RuntimeError(token: expr.paren, message: "Can only call functions and classes.")
        }
        if arguments.count != function.arity() {
            throw RuntimeError(token: expr.paren, message: "Expected \(function.arity()) arguments but got \(arguments.count).")
        }
        return try function.call(interpreter: self, arguments: arguments)
    }
    
    func visitGetExpr(_ expr: Expr.Get) throws -> Any? {
        let object = try evaluate(expr.object)
        if let instance = object as? LanguageInstance {
            return try instance.get(expr.name)
        }
        throw RuntimeError(token: expr.name, message: "Only instances have properties.")
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) throws -> Any? {
        try evaluate(expr.expression)
    }

    func visitLiteralExpr(_ expr: Expr.Literal) -> Any? {
        expr.value
    }

    func visitLogicalExpr(_ expr: Expr.Logical) throws -> Any? {
        let left = try evaluate(expr.left)
        if expr.operator.type == .or {
            if isTruthy(left) { return left }
        } else {
            if !isTruthy(left) { return left }
        }
        return try evaluate(expr.right)
    }

    func visitSetExpr(_ expr: Expr.Set) throws -> Any? {
        let object = try evaluate(expr.object)
        guard let instance = object as? LanguageInstance else {
            throw RuntimeError(token: expr.name, message: "Only instances have fields.")
        }
        let value = try evaluate(expr.value)
        let previousValue = try instance.get(expr.name)
        let newValue = try handleAssigning(expr.type, token: expr.name, previousValue: previousValue, newValue: value)
        instance.set(name: expr.name, value: newValue)
        return value
    }

    func visitSuperExpr(_ expr: Expr.Super) throws -> Any? {
        let distance = locals[expr]!
        let superclass = environment.getAt(distance: distance, name: "super").item as! LanguageClass
        let instance = environment.getAt(distance: distance - 1, name: "this").item as! LanguageInstance
        guard let method = superclass.findMethod(expr.method.lexeme) else {
            throw RuntimeError(token: expr.method, message: "Undefined property '\(expr.method.lexeme)'.")
        }
        return method.bind(instance: instance)
    }

    func visitThisExpr(_ expr: Expr.This) throws -> Any? {
        try lookUpVariable(name: expr.keyword, expr: expr).item
    }

    func visitUnaryExpr(_ expr: Expr.Unary) throws -> Any? {
        let right = try evaluate(expr.right)
        switch expr.operator.type {
        case .bang:
            return !isTruthy(right)
        case .minus:
            try checkNumberOperand(operator: expr.operator, operand: right)
            return -(right as! Double)
        default:
            return nil
        }
    }

    func visitVariableExpr(_ expr: Expr.Variable) throws -> Any? {
        let value = try lookUpVariable(name: expr.name, expr: expr).item
        guard value != nil else {
            throw RuntimeError(token: expr.name, message: "Variable not initialized.")
        }
        return value
    }
}

extension Interpreter: StmtVisitor {
    
    func visitVarStmt(_ stmt: Stmt.Var) throws -> () {
        var value: Any? = nil
        if let initializer = stmt.initializer {
            value = try evaluate(initializer)
            try checkType(token: stmt.name, type: stmt.type, value: value)
        }
        environment.define(stmt.name.lexeme, type: stmt.type, value: value)
    }

    func visitWhileStmt(_ stmt: Stmt.While) throws -> () {
        while isTruthy(try evaluate(stmt.condition)) {
            try execute(stmt.body)
        }
    }
    
    func visitBlockStmt(_ stmt: Stmt.Block) throws -> () {
        try executeBlock(statements: stmt.statements, environment: Environment(enclosing: environment))
    }
    
    func visitClassStmt(_ stmt: Stmt.Class) throws -> () {
        environment.define(stmt.name.lexeme, type: .none, value: nil)
        
        var superclass: LanguageClass? = nil
        if let superclassExpr = stmt.superclass {
            superclass = try evaluate(superclassExpr) as? LanguageClass
            if superclass == nil {
                throw RuntimeError(token: superclassExpr.name, message: "Superclass must be a class.")
            }
            environment = Environment(enclosing: environment)
            environment.define("super", type: .none, value: superclass!)
        }
        
        var methods: [String: LanguageFunction] = [:]
        for method in stmt.methods {
            let function = LanguageFunction(declaration: method, closure: environment, isInitializer: method.name.lexeme == "init")
            methods[method.name.lexeme] = function
        }
        let klass = LanguageClass(name: stmt.name.lexeme, superclass: superclass, methods: methods)
        try environment.assign(stmt.name, type: .none, value: klass)
        if stmt.superclass != nil {
            environment = environment.enclosing!
        }
    }
    
    func visitExpressionStmt(_ stmt: Stmt.Expression) throws -> () {
        _ = try evaluate(stmt.expression)
    }
    
    func visitFunctionStmt(_ stmt: Stmt.Function) throws -> () {
        let function = LanguageFunction(declaration: stmt, closure: environment, isInitializer: false)
        environment.define(stmt.name.lexeme, type: stmt.type, value: function)
    }
    
    func visitIfStmt(_ stmt: Stmt.If) throws -> () {
        if isTruthy(try evaluate(stmt.condition)) {
            try execute(stmt.thenBranch)
        } else if let elseBranch = stmt.elseBranch {
            try execute(elseBranch)
        }
    }
    
    func visitPrintStmt(_ stmt: Stmt.Print) throws -> () {
        let value = try evaluate(stmt.expression)
        if isPrintable {
            print(stringify(value))
        }
    }
    
    func visitReturnStmt(_ stmt: Stmt.Return) throws -> () {
        var value: Any? = nil
        if let returnValue = stmt.value {
            value = try evaluate(returnValue)
        }
        throw Return(value: value)
    }
}
