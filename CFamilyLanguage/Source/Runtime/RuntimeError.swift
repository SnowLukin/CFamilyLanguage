//
//  RuntimeError.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 03.04.2023.
//

import Foundation

class RuntimeError: Error {
    let token: Token
    let message: String
    
    init(token: Token, message: String) {
        self.token = token
        self.message = message
    }
}
