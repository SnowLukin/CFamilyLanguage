//
//  Return.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 06.04.2023.
//

import Foundation

class Return: Error {
    let value: Any?

    init(value: Any?) {
        self.value = value
    }
}
