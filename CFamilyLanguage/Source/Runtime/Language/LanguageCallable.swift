//
//  LanguageCallable.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

protocol LanguageCallable {
    func arity() -> Int
    func call(interpreter: Interpreter, arguments: [Any]) throws -> Any
}
