//
//  Optional+Extension.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 29.04.2023.
//

import Foundation

extension Optional where Wrapped == Any {
    func canBeCastedToSameType(as other: Wrapped?) -> Bool {
        func getType(_ value: Any?) -> String? {
            switch value {
            case _ as Int:
                return "Int"
            case _ as Double:
                return "Double"
            case _ as String:
                return "String"
            case let arrayValue as [Any]:
                if let elementType = getType(arrayValue.first) {
                    return "[\(elementType)]"
                }
            default:
                return nil
            }
            return nil
        }
        
        let type1 = getType(self)
        let type2 = getType(other)
        
        return type1 == type2
    }
}
