//
//  Language.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

class Language {
    private static let interpreter = Interpreter()
    private static let ast = AstPrinter()
    private static let rpn = RPNPrinter()
    private static let cplusPrinter = CPlusPrinter()
    static var hadError = false
    static var hadRuntimeError = false

    static func runFile(path: String) throws {
        if let bytes = FileManager.default.contents(atPath: path),
           let source = String(data: bytes, encoding: .utf8) {
            try run(source: source)
            if hadError { exit(65) }
            if hadRuntimeError { exit(70) }
        }
    }

     static func runPrompt() throws {
        while true {
            print("> ", terminator: "")
            guard let line = readLine() else { break }
            try run(source: line)
            hadError = false
        }
    }

    static func run(source: String) throws {
        let scanner = Scanner(source: source)
        let tokens = scanner.scanTokens()
        let parser = Parser(tokens: tokens)
        let statements = try parser.parse()

        if hadError {
            return
        }

        let resolver = Resolver(interpreter: interpreter)
        try resolver.resolve(statements)

        if hadError { return }
        
        do {
            
            try interpreter.interpret(statements: statements, isPrintable: true)
            
//            try ast.printNodes(statements)
//            try rpn.printNodes(statements)
//            try cplusPrinter.printCode(statements)
//            try pythonPrinter.printCode(statements)
        } catch {
            // Do nothing
        }
    }

    static func error(line: Int, message: String) {
        report(line: line, where: "", message: message)
    }

    private static func report(line: Int, `where`: String, message: String) {
        print("[line \(line)] Error\(`where`): \(message)")
        hadError = true
    }

    static func error(token: Token, message: String) {
        if token.type == .eof {
            report(line: token.line, where: " at end", message: message)
        } else {
            report(line: token.line, where: " at '\(token.lexeme)'", message: message)
        }
    }

    static func runtimeError(_ error: RuntimeError) {
        print("[line \(error.token.line)]: \(error.message)")
        hadRuntimeError = true
    }
}
