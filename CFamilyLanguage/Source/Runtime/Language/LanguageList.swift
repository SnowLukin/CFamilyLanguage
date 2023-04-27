//
//  LanguageList.swift
//  CFamilyLanguage
//
//  Created by Snow Lukin on 23.04.2023.
//

import Foundation

class LanguageList {
    private(set) var values: [Any?] = []

    func append(_ value: Any?) {
        values.append(value)
    }

    func getEleAt(_ index: Int) -> Any? {
        return index >= 0 && index < values.count ? values[index] : nil
    }

    func length() -> Int {
        return values.count
    }

    func setAtIndex(_ index: Int, value: Any?) -> Bool {
        if index == length() {
            values.insert(value, at: index)
        } else if index < length() && index >= 0 {
            values[index] = value
        } else {
            return false
        }
        return true
    }
}
