//
//  CType.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 23.04.2023.
//

import Foundation

enum CType: String, CaseIterable {
    case int = "int"
    case `string` = "string"
    case float = "float"
    case double = "double"
    case char = "char"
    case bool = "bool"
    
    case intArray = "int[]"
    case stringArray = "string[]"
    case doubleArray = "double[]"
    case floatArray = "float[]"
    case charArray = "char[]"
    case boolArray = "bool[]"
    
    case void = "void"
    
    case none = ""
    
    static func getType(from string: String, isFunction: Bool = false) -> Self {
        switch string {
        case "int":
            return .int
        case "string":
            return .string
        case "float":
            return .float
        case "double":
            return .double
        case "char":
            return .char
        case "bool":
            return .bool
        case "int[]":
            return .intArray
        case "string[]":
            return .stringArray
        case "float[]":
            return .floatArray
        case "double[]":
            return .doubleArray
        case "char[]":
            return .charArray
        case "bool[]":
            return .boolArray
        case "void" where isFunction:
            return .void
        default:
            return .none
        }
    }
}
