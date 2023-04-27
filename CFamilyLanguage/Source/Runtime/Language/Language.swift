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
    static var hadError = false
    static var hadRuntimeError = false

    static func main(args: [String]) throws {
        if args.count > 1 {
            print("Usage: lox [script]")
            exit(64)
        } else if args.count == 1 {
            try runFile(path: args[0])
        } else {
            try runPrompt()
        }
    }

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
            
            try interpreter.interpret(statements: statements)
            
            /// Remove comments below to see RPN representation of the code tree
//            for statement in statements {
//                print(try ast.printNode(statement))
//            }
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
