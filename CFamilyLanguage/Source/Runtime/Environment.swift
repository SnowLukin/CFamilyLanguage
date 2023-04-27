//
//  Environment.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

class Environment {
    typealias Info = (type: CType, item: Any?)
    
    let enclosing: Environment?
    private var values: [String: Info] = [:]

    init() {
        enclosing = nil
    }

    init(enclosing: Environment) {
        self.enclosing = enclosing
    }

    func get(_ name: Token) throws -> Info {
        if let value = values[name.lexeme] {
            return value
        }

        if let enclosingEnvironment = enclosing {
            return try enclosingEnvironment.get(name)
        }
        throw RuntimeError(token: name, message: "Undefined variable '\(name.lexeme)'.")
    }
    
    func assign(_ name: Token, type: CType, value: Any?) throws {
        if values.keys.contains(name.lexeme) {
            values[name.lexeme] = (type, value)
            return
        }

        if let enclosingEnvironment = enclosing {
            try enclosingEnvironment.assign(name, type: type, value: value)
            return
        }
        
        throw RuntimeError(token: name, message: "Undefined variable '\(name.lexeme)'.")
    }
    
    func define(_ name: String, type: CType, value: Any?) {
        values[name] = (type, value)
    }

    func ancestor(distance: Int) -> Environment {
        var environment = self
        for _ in 0..<distance {
            environment = environment.enclosing!
        }

        return environment
    }

    func getAt(distance: Int, name: String) -> Info {
        return ancestor(distance: distance).values[name]!
    }
    
    func assignAt(distance: Int, name: Token, type: CType, value: Any?) {
        ancestor(distance: distance).values[name.lexeme] = (type, value)
    }
    
}
