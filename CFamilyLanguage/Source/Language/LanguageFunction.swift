//
//  LanguageFunction.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

class LanguageFunction: LanguageCallable {

    private let declaration: Stmt.Function
    private let closure: Environment
    private let isInitializer: Bool

    init(declaration: Stmt.Function, closure: Environment, isInitializer: Bool) {
        self.declaration = declaration
        self.closure = closure
        self.isInitializer = isInitializer
    }

    func bind(instance: LanguageInstance) -> LanguageFunction {
        let environment = Environment(enclosing: closure)
        environment.define("this", type: .none, value: instance)
        return LanguageFunction(declaration: declaration, closure: environment, isInitializer: isInitializer)
    }

    var description: String {
        return "<fn \(declaration.name.lexeme)>"
    }

    func arity() -> Int {
        return declaration.params.count
    }

    func call(interpreter: Interpreter, arguments: [Any]) throws -> Any {
        let environment = Environment(enclosing: closure)
        for i in 0..<declaration.params.count {
            environment.define(declaration.params[i].name.lexeme, type: .none, value: arguments[i])
        }

        do {
            try interpreter.executeBlock(statements: declaration.body, environment: environment)
        } catch let returnValue as Return {
            if isInitializer {
                return closure.getAt(distance: 0, name: "this")
            }
            return returnValue.value ?? ()
        } catch {
            return ()
        }

        if isInitializer {
            return closure.getAt(distance: 0, name: "this")
        }
        return ()
    }
}
