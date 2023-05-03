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
    
    static func runFile(rootFilePath: String) throws {
        let rootFileURL = URL(fileURLWithPath: rootFilePath).deletingLastPathComponent()
        let languageFileURL = rootFileURL.appendingPathComponent("Examples/language")
        do {
            let contents = try String(contentsOf: languageFileURL, encoding: .utf8)
            try run(source: contents, rootFileURL: rootFileURL)
            if hadError { exit(65) }
            if hadRuntimeError { exit(70) }
        } catch {
            print("Error reading file: \(error)")
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
    
    static func run(source: String, rootFileURL: URL? = nil) throws {
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
            
            let ast = try ast.getNodes(statements)
            let rpn = try rpn.getNodes(statements)
            let cplus = try cplusPrinter.getNodes(statements)
            
            if let rootFileURL = rootFileURL {
                let astFileURL = rootFileURL.appendingPathComponent("Examples/ast")
                let rpnFileURL = rootFileURL.appendingPathComponent("Examples/rpn")
                let cplusFileURL = rootFileURL.appendingPathComponent("Examples/cplus")
                do {
                    try ast.write(to: astFileURL, atomically: true, encoding: .utf8)
                    try rpn.write(to: rpnFileURL, atomically: true, encoding: .utf8)
                    try cplus.write(to: cplusFileURL, atomically: true, encoding: .utf8)
                } catch {
                    print("Failed to write to the file: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error in Language.swift")
            print(error.localizedDescription)
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
