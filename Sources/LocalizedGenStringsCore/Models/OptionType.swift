//
//  OptionType.swift
//  AEXML
//
//  Created by Timur Shafigullin on 21/07/2019.
//

import Foundation

enum OptionType: String {

    // MARK: - Enumeration Cases

    case path = "path"
    case lang = "lang"
    case key = "key"

    // MARK: - Type Methods

    static func parse(from arguments: [String]) throws -> [OptionType: String] {
        return [:]
    }
}
