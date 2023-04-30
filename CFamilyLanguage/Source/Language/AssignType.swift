//
//  AssignType.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 30.04.2023.
//

import Foundation

enum AssignType: String, CaseIterable {
    case assign = "="
    case plusAssign = "+="
    case minusAssign = "-="
    case slashAssign = "/="
    case starAssign = "*="
    
    static func getType(from string: String) -> Self? {
        switch string {
        case "=":
            return .assign
        case "+=":
            return .plusAssign
        case "-=":
            return .minusAssign
        case "/=":
            return .slashAssign
        case "*=":
            return .starAssign
        default:
            return .none
        }
    }
}
