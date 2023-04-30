//
//  Numeric+Extension.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 29.04.2023.
//

import Foundation

extension Numeric {
    static func performOperation(_ operation: (Self, Self) -> Self, _ value1: Any?, _ value2: Any?) -> Self? {
        if let value1 = value1 as? Self, let value2 = value2 as? Self {
            return operation(value1, value2)
        }
        return nil
    }
    
    static func performComparison(_ operation: (Self, Self) -> Bool, _ value1: Any?, _ value2: Any?) -> Bool? {
        if let value1 = value1 as? Self, let value2 = value2 as? Self {
            return operation(value1, value2)
        }
        return nil
    }
}
