//
//  LanguageClass.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

class LanguageClass: LanguageCallable {
    let name: String
    let superclass: LanguageClass?
    private let methods: [String: LanguageFunction]

    init(name: String, superclass: LanguageClass?, methods: [String: LanguageFunction]) {
        self.name = name
        self.superclass = superclass
        self.methods = methods
    }

    func findMethod(_ name: String) -> LanguageFunction? {
        if let method = methods[name] {
            return method
        }

        if let superClass = superclass {
            return superClass.findMethod(name)
        }

        return nil
    }

    var description: String {
        return "<class \(name)>"
    }

    func call(interpreter: Interpreter, arguments: [Any]) throws -> Any {
        let instance = LanguageInstance(class: self)
        if let initializer = findMethod("init") {
            _ = try initializer.bind(instance: instance).call(interpreter: interpreter, arguments: arguments as [Any])
        }
        return instance
    }

    func arity() -> Int {
        guard let initializer = findMethod("init") else { return 0 }
        return initializer.arity()
    }
}
