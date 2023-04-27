//
//  CType.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 23.04.2023.
//

import Foundation

enum CType: String, CaseIterable {
    case int
    case `string`
    case float
    case double
    case char
    case bool
    
    case intArray
    case stringArray
    case doubleArray
    case floatArray
    case charArray
    case boolArray
    
    case void
    
    case none
    
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
