//
//  LanguageInstance.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

class LanguageInstance {
    private let `class`: LanguageClass
    private var fields: [String: Any] = [:]

    init(`class`: LanguageClass) {
        self.`class` = `class`
    }

    func get(_ name: Token) throws -> Any {
        if let value = fields[name.lexeme] {
            return value
        }

        if let method = `class`.findMethod(name.lexeme) {
            return method.bind(instance: self)
        }

        throw RuntimeError(token: name, message: "Undefined property '\(name.lexeme)'.")
    }

    func set(name: Token, value: Any?) {
        fields[name.lexeme] = value
    }

    var description: String {
        return "\(`class`.name) instance"
    }
}
