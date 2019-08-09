//
//  Translator.swift
//  LocalizedGenStringsCore
//
//  Created by Timur Shafigullin on 21/07/2019.
//

import Foundation

public protocol Translator {

    // MARK: - Instance Methods

    func translate(localizedStrings strings: [String], to lang: String, key: String) -> [String]?
}
